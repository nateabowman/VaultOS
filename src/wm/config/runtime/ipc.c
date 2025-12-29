/*
 * VaultWM IPC (Inter-Process Communication)
 * FIFO-based IPC for external script control
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#define IPC_FIFO_PATH_MAX 256
#define IPC_CMD_MAX 128
#define IPC_FIFO_MODE 0666

static char ipc_fifo_path[IPC_FIFO_PATH_MAX];
static int ipc_fifo_fd = -1;

/* Create IPC FIFO */
int ipc_init(void) {
    const char *home = getenv("HOME");
    if (!home) return 0;
    
    snprintf(ipc_fifo_path, sizeof(ipc_fifo_path), "%s/.config/vaultwm/vaultwm_ipc", home);
    
    /* Create directory if it doesn't exist */
    char dir_path[IPC_FIFO_PATH_MAX];
    strncpy(dir_path, ipc_fifo_path, sizeof(dir_path));
    char *last_slash = strrchr(dir_path, '/');
    if (last_slash) {
        *last_slash = '\0';
        mkdir(dir_path, 0755);
    }
    
    /* Remove existing FIFO if present */
    unlink(ipc_fifo_path);
    
    /* Create FIFO */
    if (mkfifo(ipc_fifo_path, IPC_FIFO_MODE) < 0) {
        if (errno != EEXIST) {
            perror("mkfifo");
            return 0;
        }
    }
    
    return 1;
}

/* Clean up IPC FIFO */
void ipc_cleanup(void) {
    if (ipc_fifo_fd >= 0) {
        close(ipc_fifo_fd);
        ipc_fifo_fd = -1;
    }
    unlink(ipc_fifo_path);
}

/* Process IPC command */
void ipc_process_command(const char *cmd) {
    if (!cmd) return;
    
    /* Parse and execute commands */
    /* Format: command [arguments] */
    /* Commands: focus_next, focus_prev, switch_workspace N, close_window, etc. */
    
    /* This will be called from the main event loop to process IPC commands */
    /* Implementation depends on WM internals */
}

/* Check for IPC commands (non-blocking) */
int ipc_check_commands(void) {
    if (ipc_fifo_fd < 0) {
        ipc_fifo_fd = open(ipc_fifo_path, O_RDONLY | O_NONBLOCK);
        if (ipc_fifo_fd < 0) return 0;
    }
    
    char cmd[IPC_CMD_MAX];
    ssize_t n = read(ipc_fifo_fd, cmd, sizeof(cmd) - 1);
    
    if (n > 0) {
        cmd[n] = '\0';
        ipc_process_command(cmd);
        return 1;
    }
    
    return 0;
}

/* Send command to WM via IPC (for external scripts) */
int ipc_send_command(const char *cmd) {
    const char *home = getenv("HOME");
    if (!home) return 0;
    
    char fifo_path[IPC_FIFO_PATH_MAX];
    snprintf(fifo_path, sizeof(fifo_path), "%s/.config/vaultwm/vaultwm_ipc", home);
    
    int fd = open(fifo_path, O_WRONLY | O_NONBLOCK);
    if (fd < 0) return 0;
    
    write(fd, cmd, strlen(cmd));
    close(fd);
    return 1;
}

/* Get IPC FIFO path (for external scripts) */
const char* ipc_get_fifo_path(void) {
    static char path[IPC_FIFO_PATH_MAX];
    const char *home = getenv("HOME");
    if (!home) return NULL;
    snprintf(path, sizeof(path), "%s/.config/vaultwm/vaultwm_ipc", home);
    return path;
}

