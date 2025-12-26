/*
 * VaultWM Configuration Header
 * Customize window manager behavior here
 */

#ifndef VAULTWM_CONFIG_H
#define VAULTWM_CONFIG_H

/* Colors (Pip-Boy theme) */
#define COLOR_PIPBOY_GREEN 0x00FF41
#define COLOR_BLACK 0x000000
#define COLOR_DARK_GREEN 0x003300
#define COLOR_AMBER 0xFFBF00

/* Dimensions */
#define STATUS_BAR_HEIGHT 30
#define BORDER_WIDTH 2
#define GAP_SIZE 5

/* Key bindings (Mod4 = Super/Windows key) */
#define MOD_KEY Mod4Mask

/* Terminal command */
#define TERMINAL_CMD "alacritty"
#define TERMINAL_FALLBACK "xterm"

/* Status bar update interval (seconds) */
#define STATUS_UPDATE_INTERVAL 1

#endif /* VAULTWM_CONFIG_H */

