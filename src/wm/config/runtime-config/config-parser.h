/*
 * VaultWM Configuration Parser
 * Runtime configuration file parsing
 */

#ifndef VAULTWM_CONFIG_PARSER_H
#define VAULTWM_CONFIG_PARSER_H

#define CONFIG_FILE_MAX_SIZE 8192
#define CONFIG_LINE_MAX 256
#define CONFIG_KEY_MAX 64
#define CONFIG_VALUE_MAX 128

typedef struct {
    int border_width;
    unsigned long border_color_focused;
    unsigned long border_color_unfocused;
    unsigned long border_color_urgent;
    int gap_size;
    int status_bar_height;
    int status_bar_update_interval;
    char terminal_cmd[64];
    char terminal_fallback[64];
    char launcher_cmd[64];
    char launcher_fallback[64];
    int default_layout;  // 0=tiling, 1=floating, 2=monocle, 3=grid, 4=fibonacci
    char workspace_names[9][32];
} VaultWMConfig;

/* Load configuration from file */
int load_config(const char *config_path, VaultWMConfig *config);

/* Get default configuration */
void get_default_config(VaultWMConfig *config);

/* Parse a single config line */
int parse_config_line(const char *line, VaultWMConfig *config);

#endif /* VAULTWM_CONFIG_PARSER_H */

