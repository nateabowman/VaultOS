/*
 * VaultWM IPC Implementation
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <errno.h>
#include <ctype.h>
#include "ipc.h"

static int ipc_fifo_fd = -1;
static int ipc_initialized = 0;
static ipc_command_handler_t command_handler = NULL;

// Command whitelist - only these commands are allowed
static const char *allowed_commands[] = {
    IPC_CMD_QUIT,
    IPC_CMD_RELOAD,
    IPC_CMD_WORKSPACE,
    IPC_CMD_MOVE_TO_WORKSPACE,
    IPC_CMD_FOCUS_NEXT,
    IPC_CMD_FOCUS_PREV,
    IPC_CMD_CLOSE_WINDOW,
    IPC_CMD_TOGGLE_FLOAT,
    IPC_CMD_TOGGLE_LAYOUT,
    IPC_CMD_GET_STATUS,
    NULL
};

// Check if command is in whitelist
static int is_command_allowed(const char *cmd) {
    int i;
    for (i = 0; allowed_commands[i] != NULL; i++) {
        if (strncmp(cmd, allowed_commands[i], IPC_CMD_MAX) == 0) {
            return 1;
        }
    }
    return 0;
}

// Validate command string (no control characters, reasonable length)
static int validate_command(const char *cmd, size_t len) {
    size_t i;
    
    // Check length
    if (len == 0 || len >= IPC_CMD_MAX) {
        return 0;
    }
    
    // Check for control characters (except newline which we handle separately)
    for (i = 0; i < len; i++) {
        if (cmd[i] == '\0') break;
        if (iscntrl(cmd[i]) && cmd[i] != '\n' && cmd[i] != '\r') {
            return 0;
        }
    }
    
    return 1;
}

int ipc_init(void) {
    // Remove existing FIFO if it exists
    unlink(IPC_FIFO_PATH);
    
    // Create FIFO with secure permissions (0600 = owner read/write only)
    if (mkfifo(IPC_FIFO_PATH, 0600) < 0 && errno != EEXIST) {
        fprintf(stderr, "VaultWM: Failed to create IPC FIFO: %s\n", IPC_FIFO_PATH);
        return 0;
    }
    
    // Set secure permissions explicitly (in case FIFO already existed)
    if (chmod(IPC_FIFO_PATH, 0600) < 0) {
        fprintf(stderr, "VaultWM: Failed to set IPC FIFO permissions: %s\n", strerror(errno));
        unlink(IPC_FIFO_PATH);
        return 0;
    }
    
    // Open FIFO in non-blocking mode
    ipc_fifo_fd = open(IPC_FIFO_PATH, O_RDONLY | O_NONBLOCK);
    if (ipc_fifo_fd < 0) {
        fprintf(stderr, "VaultWM: Failed to open IPC FIFO: %s\n", strerror(errno));
        unlink(IPC_FIFO_PATH);
        return 0;
    }
    
    ipc_initialized = 1;
    return 1;
}

void ipc_cleanup(void) {
    if (ipc_fifo_fd >= 0) {
        close(ipc_fifo_fd);
        ipc_fifo_fd = -1;
    }
    unlink(IPC_FIFO_PATH);
    ipc_initialized = 0;
}

void ipc_send_response(const char *response) {
    // For now, responses are written to stdout/stderr
    // In a full implementation, we could use a response FIFO
    fprintf(stdout, "VaultWM IPC: %s\n", response);
    fflush(stdout);
}

/* Parse command and arguments from input string */
int ipc_parse_command(const char *input, char *cmd, size_t cmd_size, char *args, size_t args_size) {
    const char *space;
    size_t cmd_len;
    
    if (!input || !cmd || !args || cmd_size == 0 || args_size == 0) {
        return 0;
    }
    
    // Find first space (separates command from arguments)
    space = strchr(input, ' ');
    
    if (space == NULL) {
        // No arguments, command is the entire input
        cmd_len = strlen(input);
        if (cmd_len >= cmd_size) {
            return 0;  // Command too long
        }
        strncpy(cmd, input, cmd_size - 1);
        cmd[cmd_size - 1] = '\0';
        args[0] = '\0';
        return 1;
    }
    
    // Extract command (before space)
    cmd_len = (size_t)(space - input);
    if (cmd_len >= cmd_size) {
        return 0;  // Command too long
    }
    strncpy(cmd, input, cmd_len);
    cmd[cmd_len] = '\0';
    
    // Extract arguments (after space, skip leading spaces)
    space++;
    while (*space == ' ') space++;  // Skip multiple spaces
    
    size_t args_len = strlen(space);
    if (args_len >= args_size) {
        args_len = args_size - 1;
    }
    strncpy(args, space, args_len);
    args[args_len] = '\0';
    
    return 1;
}

/* Set command handler callback */
void ipc_set_command_handler(ipc_command_handler_t handler) {
    command_handler = handler;
}

void ipc_process_commands(void) {
    char input[IPC_CMD_MAX];
    char cmd[IPC_CMD_MAX];
    char args[IPC_CMD_MAX];
    ssize_t bytes_read;
    size_t input_len;
    
    if (!ipc_initialized || ipc_fifo_fd < 0) {
        return;
    }
    
    // Read command from FIFO (non-blocking) with bounds checking
    bytes_read = read(ipc_fifo_fd, input, IPC_CMD_MAX - 1);
    
    if (bytes_read < 0) {
        // Error reading (likely EAGAIN/EWOULDBLOCK for non-blocking)
        if (errno != EAGAIN && errno != EWOULDBLOCK) {
            fprintf(stderr, "VaultWM IPC: Error reading from FIFO: %s\n", strerror(errno));
        }
        return;
    }
    
    if (bytes_read == 0) {
        // EOF - no data available
        return;
    }
    
    // Ensure null termination
    if (bytes_read >= IPC_CMD_MAX - 1) {
        bytes_read = IPC_CMD_MAX - 1;
    }
    input[bytes_read] = '\0';
    
    // Remove trailing newline and carriage return
    while (bytes_read > 0 && (input[bytes_read - 1] == '\n' || input[bytes_read - 1] == '\r')) {
        bytes_read--;
        input[bytes_read] = '\0';
    }
    
    input_len = (size_t)bytes_read;
    
    // Validate input
    if (!validate_command(input, input_len)) {
        ipc_send_response("ERROR: Invalid command format");
        return;
    }
    
    // Parse command and arguments
    if (!ipc_parse_command(input, cmd, sizeof(cmd), args, sizeof(args))) {
        ipc_send_response("ERROR: Failed to parse command");
        return;
    }
    
    // Check command whitelist (check base command, not with arguments)
    if (!is_command_allowed(cmd)) {
        ipc_send_response("ERROR: Command not allowed");
        return;
    }
    
    // Call command handler if set
    if (command_handler != NULL) {
        command_handler(cmd, args);
        ipc_send_response("OK: Command executed");
    } else {
        // No handler set, just acknowledge
        ipc_send_response("OK: Command received (no handler)");
    }
}

