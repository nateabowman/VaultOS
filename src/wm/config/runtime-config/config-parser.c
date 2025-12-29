/*
 * VaultWM Configuration Parser Implementation
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pwd.h>
#include "config-parser.h"

void get_default_config(VaultWMConfig *config) {
    config->border_width = 2;
    config->border_color_focused = 0x00FF41;
    config->border_color_unfocused = 0x003300;
    config->border_color_urgent = 0xFF0000;
    config->gap_size = 5;
    config->status_bar_height = 30;
    config->status_bar_update_interval = 1;
    
    // Use strncpy with explicit null termination for safety
    strncpy(config->terminal_cmd, "alacritty", sizeof(config->terminal_cmd) - 1);
    config->terminal_cmd[sizeof(config->terminal_cmd) - 1] = '\0';
    
    strncpy(config->terminal_fallback, "xterm", sizeof(config->terminal_fallback) - 1);
    config->terminal_fallback[sizeof(config->terminal_fallback) - 1] = '\0';
    
    strncpy(config->launcher_cmd, "dmenu_run", sizeof(config->launcher_cmd) - 1);
    config->launcher_cmd[sizeof(config->launcher_cmd) - 1] = '\0';
    
    strncpy(config->launcher_fallback, "rofi -show drun", sizeof(config->launcher_fallback) - 1);
    config->launcher_fallback[sizeof(config->launcher_fallback) - 1] = '\0';
    
    config->default_layout = 0;  // tiling
    
    // Default workspace names
    int i;
    for (i = 0; i < 9; i++) {
        char ws_name[2];
        snprintf(ws_name, sizeof(ws_name), "%d", i + 1);
        strncpy(config->workspace_names[i], ws_name, sizeof(config->workspace_names[i]) - 1);
        config->workspace_names[i][sizeof(config->workspace_names[i]) - 1] = '\0';
    }
}

int parse_config_line(const char *line, VaultWMConfig *config) {
    char key[CONFIG_KEY_MAX];
    char value[CONFIG_VALUE_MAX];
    char line_copy[CONFIG_LINE_MAX];
    int i, j;
    
    // Skip empty lines and comments
    if (line[0] == '\0' || line[0] == '#' || line[0] == '\n') {
        return 0;
    }
    
    strncpy(line_copy, line, CONFIG_LINE_MAX - 1);
    line_copy[CONFIG_LINE_MAX - 1] = '\0';
    
    // Remove trailing whitespace and newline
    for (i = strlen(line_copy) - 1; i >= 0 && (line_copy[i] == ' ' || line_copy[i] == '\t' || line_copy[i] == '\n' || line_copy[i] == '\r'); i--) {
        line_copy[i] = '\0';
    }
    
    // Find = sign
    char *eq = strchr(line_copy, '=');
    if (!eq) return 0;
    
    // Extract key (left side of =)
    for (i = 0; line_copy[i] != '=' && i < CONFIG_KEY_MAX - 1; i++) {
        key[i] = line_copy[i];
    }
    key[i] = '\0';
    
    // Remove trailing whitespace from key
    for (i = strlen(key) - 1; i >= 0 && (key[i] == ' ' || key[i] == '\t'); i--) {
        key[i] = '\0';
    }
    
    // Extract value (right side of =)
    for (i = 0, j = (int)(eq - line_copy) + 1; line_copy[j] != '\0' && i < CONFIG_VALUE_MAX - 1; i++, j++) {
        value[i] = line_copy[j];
    }
    value[i] = '\0';
    
    // Remove leading whitespace from value
    for (i = 0; value[i] == ' ' || value[i] == '\t'; i++);
    if (i > 0) {
        memmove(value, value + i, strlen(value) - i + 1);
    }
    
    // Parse configuration values
    if (strcmp(key, "border_width") == 0) {
        config->border_width = atoi(value);
    } else if (strcmp(key, "border_color_focused") == 0) {
        config->border_color_focused = strtoul(value, NULL, 16);
    } else if (strcmp(key, "border_color_unfocused") == 0) {
        config->border_color_unfocused = strtoul(value, NULL, 16);
    } else if (strcmp(key, "border_color_urgent") == 0) {
        config->border_color_urgent = strtoul(value, NULL, 16);
    } else if (strcmp(key, "gap_size") == 0) {
        config->gap_size = atoi(value);
    } else if (strcmp(key, "status_bar_height") == 0) {
        config->status_bar_height = atoi(value);
    } else if (strcmp(key, "status_bar_update_interval") == 0) {
        config->status_bar_update_interval = atoi(value);
    } else if (strcmp(key, "terminal_cmd") == 0) {
        strncpy(config->terminal_cmd, value, sizeof(config->terminal_cmd) - 1);
        config->terminal_cmd[sizeof(config->terminal_cmd) - 1] = '\0';
    } else if (strcmp(key, "terminal_fallback") == 0) {
        strncpy(config->terminal_fallback, value, sizeof(config->terminal_fallback) - 1);
        config->terminal_fallback[sizeof(config->terminal_fallback) - 1] = '\0';
    } else if (strcmp(key, "launcher_cmd") == 0) {
        strncpy(config->launcher_cmd, value, sizeof(config->launcher_cmd) - 1);
        config->launcher_cmd[sizeof(config->launcher_cmd) - 1] = '\0';
    } else if (strcmp(key, "launcher_fallback") == 0) {
        strncpy(config->launcher_fallback, value, sizeof(config->launcher_fallback) - 1);
        config->launcher_fallback[sizeof(config->launcher_fallback) - 1] = '\0';
    } else if (strcmp(key, "default_layout") == 0) {
        if (strcmp(value, "tiling") == 0) config->default_layout = 0;
        else if (strcmp(value, "floating") == 0) config->default_layout = 1;
        else if (strcmp(value, "monocle") == 0) config->default_layout = 2;
        else if (strcmp(value, "grid") == 0) config->default_layout = 3;
        else if (strcmp(value, "fibonacci") == 0) config->default_layout = 4;
    } else if (strncmp(key, "workspace_", 10) == 0) {
        int ws_num = atoi(key + 10);
        if (ws_num >= 1 && ws_num <= 9) {
            strncpy(config->workspace_names[ws_num - 1], value, sizeof(config->workspace_names[0]) - 1);
            config->workspace_names[ws_num - 1][sizeof(config->workspace_names[0]) - 1] = '\0';
        }
    }
    
    return 1;
}

int load_config(const char *config_path, VaultWMConfig *config) {
    FILE *file;
    char line[CONFIG_LINE_MAX];
    char expanded_path[512];
    struct stat st;
    
    if (!config_path || !config) {
        return 0;
    }
    
    // Get default config first
    get_default_config(config);
    
    // Expand ~ to home directory
    if (config_path[0] == '~') {
        struct passwd *pw = getpwuid(getuid());
        if (!pw) {
            return 0;  // Cannot get home directory
        }
        snprintf(expanded_path, sizeof(expanded_path), "%s%s", pw->pw_dir, config_path + 1);
        config_path = expanded_path;
    }
    
    // Validate file path (prevent directory traversal)
    if (strstr(config_path, "..") != NULL) {
        return 0;  // Reject paths with ..
    }
    
    // Check if file exists and is readable
    if (stat(config_path, &st) != 0) {
        return 0;  // File doesn't exist, use defaults
    }
    
    // Verify it's a regular file
    if (!S_ISREG(st.st_mode)) {
        return 0;  // Not a regular file
    }
    
    // Check file size (prevent reading huge files)
    if (st.st_size > CONFIG_FILE_MAX_SIZE) {
        return 0;  // File too large
    }
    
    file = fopen(config_path, "r");
    if (!file) {
        return 0;  // Cannot open file, use defaults
    }
    
    // Read file line by line with bounds checking
    while (fgets(line, sizeof(line), file)) {
        // Check for buffer overflow (line too long)
        if (strlen(line) >= CONFIG_LINE_MAX - 1 && line[CONFIG_LINE_MAX - 2] != '\n') {
            // Line too long, skip it
            int c;
            while ((c = fgetc(file)) != EOF && c != '\n');
            continue;
        }
        parse_config_line(line, config);
    }
    
    if (ferror(file)) {
        fclose(file);
        return 0;  // Error reading file
    }
    
    fclose(file);
    return 1;
}

