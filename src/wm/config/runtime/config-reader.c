/*
 * VaultWM Configuration File Reader
 * Reads and parses runtime configuration file
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define CONFIG_PATH_MAX 512
#define CONFIG_LINE_MAX 256
#define CONFIG_VALUE_MAX 128

typedef struct {
    char terminal[128];
    char terminal_fallback[128];
    char launcher[128];
    char launcher_fallback[128];
    int status_update_interval;
    int window_gap;
    int border_width;
    unsigned long color_focused;
    unsigned long color_unfocused;
    unsigned long color_urgent;
    unsigned long color_background;
    int status_bar_height;
    int status_bar_enabled;
    int default_layout;  // 0=tiling, 1=floating, 2=monocle
    int layout_gap;
} VaultWMConfig;

VaultWMConfig config;

/* Convert hex color string to unsigned long */
unsigned long hex_to_color(const char *hex) {
    if (!hex || hex[0] != '#') return 0;
    unsigned long color = 0;
    sscanf(hex + 1, "%lx", &color);
    return color;
}

/* Trim whitespace from string */
void trim(char *str) {
    char *start = str;
    char *end = str + strlen(str) - 1;
    
    while (isspace(*start)) start++;
    while (end > start && isspace(*end)) end--;
    
    end[1] = '\0';
    memmove(str, start, end - start + 2);
}

/* Read configuration file */
int read_config(const char *config_path) {
    FILE *fp = fopen(config_path, "r");
    if (!fp) return 0;
    
    char line[CONFIG_LINE_MAX];
    
    /* Set defaults */
    strcpy(config.terminal, "alacritty");
    strcpy(config.terminal_fallback, "xterm");
    strcpy(config.launcher, "dmenu_run");
    strcpy(config.launcher_fallback, "rofi -show drun");
    config.status_update_interval = 1;
    config.window_gap = 5;
    config.border_width = 2;
    config.color_focused = 0x00FF41;
    config.color_unfocused = 0x003300;
    config.color_urgent = 0xFF0000;
    config.color_background = 0x000000;
    config.status_bar_height = 30;
    config.status_bar_enabled = 1;
    config.default_layout = 0;
    config.layout_gap = 5;
    
    while (fgets(line, sizeof(line), fp)) {
        /* Skip comments and empty lines */
        trim(line);
        if (line[0] == '#' || line[0] == '\0') continue;
        
        char *eq = strchr(line, '=');
        if (!eq) continue;
        
        *eq = '\0';
        char *key = line;
        char *value = eq + 1;
        trim(key);
        trim(value);
        
        /* Parse configuration values */
        if (strcmp(key, "terminal") == 0) {
            strncpy(config.terminal, value, sizeof(config.terminal) - 1);
        } else if (strcmp(key, "terminal_fallback") == 0) {
            strncpy(config.terminal_fallback, value, sizeof(config.terminal_fallback) - 1);
        } else if (strcmp(key, "launcher") == 0) {
            strncpy(config.launcher, value, sizeof(config.launcher) - 1);
        } else if (strcmp(key, "launcher_fallback") == 0) {
            strncpy(config.launcher_fallback, value, sizeof(config.launcher_fallback) - 1);
        } else if (strcmp(key, "status_update_interval") == 0) {
            config.status_update_interval = atoi(value);
        } else if (strcmp(key, "window_gap") == 0) {
            config.window_gap = atoi(value);
        } else if (strcmp(key, "border_width") == 0) {
            config.border_width = atoi(value);
        } else if (strcmp(key, "color_focused") == 0) {
            config.color_focused = hex_to_color(value);
        } else if (strcmp(key, "color_unfocused") == 0) {
            config.color_unfocused = hex_to_color(value);
        } else if (strcmp(key, "color_urgent") == 0) {
            config.color_urgent = hex_to_color(value);
        } else if (strcmp(key, "color_background") == 0) {
            config.color_background = hex_to_color(value);
        } else if (strcmp(key, "status_bar_height") == 0) {
            config.status_bar_height = atoi(value);
        } else if (strcmp(key, "status_bar_enabled") == 0) {
            config.status_bar_enabled = (strcmp(value, "true") == 0 || strcmp(value, "1") == 0);
        } else if (strcmp(key, "default_layout") == 0) {
            if (strcmp(value, "tiling") == 0) config.default_layout = 0;
            else if (strcmp(value, "floating") == 0) config.default_layout = 1;
            else if (strcmp(value, "monocle") == 0) config.default_layout = 2;
        } else if (strcmp(key, "layout_gap") == 0) {
            config.layout_gap = atoi(value);
        }
    }
    
    fclose(fp);
    return 1;
}

/* Get configuration file path */
const char* get_config_path(void) {
    static char path[CONFIG_PATH_MAX];
    const char *home = getenv("HOME");
    if (!home) return NULL;
    snprintf(path, sizeof(path), "%s/.config/vaultwm/config", home);
    return path;
}

