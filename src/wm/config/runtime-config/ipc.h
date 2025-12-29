/*
 * VaultWM IPC (Inter-Process Communication)
 * Named pipe (FIFO) based IPC for external script control
 */

#ifndef VAULTWM_IPC_H
#define VAULTWM_IPC_H

#define IPC_FIFO_PATH "/tmp/vaultwm-ipc"
#define IPC_CMD_MAX 256
#define IPC_RESPONSE_MAX 512

/* IPC Commands */
#define IPC_CMD_QUIT "quit"
#define IPC_CMD_RELOAD "reload"
#define IPC_CMD_WORKSPACE "workspace"
#define IPC_CMD_MOVE_TO_WORKSPACE "move_to_workspace"
#define IPC_CMD_FOCUS_NEXT "focus_next"
#define IPC_CMD_FOCUS_PREV "focus_prev"
#define IPC_CMD_CLOSE_WINDOW "close_window"
#define IPC_CMD_TOGGLE_FLOAT "toggle_float"
#define IPC_CMD_TOGGLE_LAYOUT "toggle_layout"
#define IPC_CMD_GET_STATUS "get_status"

/* Initialize IPC */
int ipc_init(void);

/* Cleanup IPC */
void ipc_cleanup(void);

/* Process IPC commands */
void ipc_process_commands(void);

/* Send IPC response */
void ipc_send_response(const char *response);

/* Command handler callback type */
typedef void (*ipc_command_handler_t)(const char *cmd, const char *args);

/* Set command handler callback */
void ipc_set_command_handler(ipc_command_handler_t handler);

/* Parse command and arguments from input string */
int ipc_parse_command(const char *input, char *cmd, size_t cmd_size, char *args, size_t args_size);

#endif /* VAULTWM_IPC_H */

