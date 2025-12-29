/*
 * VaultWM - VaultOS Window Manager
 * A lightweight, Fallout-themed window manager for X11
 * Features: Tiling/floating modes, Pip-Boy-style status bar
 */

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <time.h>
#include <sys/select.h>
#include <sys/time.h>
#include <ctype.h>
#include "../config/config.h"
#include "../monitor/monitor.h"
#include "../window-rules/window-rules.h"

#define MAX_WINDOWS 256
#define PIPBOY_GREEN COLOR_PIPBOY_GREEN
#define BLACK COLOR_BLACK
#define DARK_GREEN COLOR_DARK_GREEN

typedef struct {
    Window win;
    int x, y, width, height;
    int is_floating;
    int is_mapped;
} Client;

typedef struct Workspace {
    Client clients[MAX_WINDOWS];
    int num_clients;
    int layout_mode;  // 0 = tiling, 1 = floating, 2 = monocle
} Workspace;

typedef struct {
    Display *dpy;
    Window root;
    int screen;
    int screen_width, screen_height;
    Workspace workspaces[MAX_WORKSPACES];
    int current_workspace;
    int current_client;
    Window status_bar;
    GC gc;
    Atom wm_protocols;
    Atom wm_delete_window;
    int is_resizing;
    int is_moving;
    int resize_start_x, resize_start_y;
    int move_start_x, move_start_y;
    MonitorManager monitor_mgr;  // Multi-monitor support
    int current_monitor;  // Currently active monitor
    WindowRules window_rules;  // Window rules system
} VaultWM;

VaultWM wm;

/* Forward declarations */
void setup_wm(void);
void cleanup_wm(void);
void handle_event(XEvent *e);
void handle_keypress(XKeyEvent *e);
void handle_buttonpress(XButtonEvent *e);
void handle_motion_notify(XMotionEvent *e);
void handle_configure_request(XConfigureRequestEvent *e);
void handle_map_request(XMapRequestEvent *e);
void handle_unmap_notify(XUnmapEvent *e);
void manage_window(Window w);
void unmanage_window(Window w);
void tile_windows(void);
void draw_status_bar(void);
void update_status_bar(void);
void focus_client(int index);
void focus_next(void);
void focus_prev(void);
void switch_workspace(int workspace);
void move_client(int index, int dx, int dy);
void resize_client(int index, int dw, int dh);
void launch_application(const char *cmd);
Workspace* current_workspace(void);

void setup_wm(void) {
    wm.dpy = XOpenDisplay(NULL);
    if (!wm.dpy) {
        fprintf(stderr, "VaultWM: Cannot open display\n");
        exit(1);
    }

    wm.screen = DefaultScreen(wm.dpy);
    wm.root = RootWindow(wm.dpy, wm.screen);
    wm.screen_width = DisplayWidth(wm.dpy, wm.screen);
    wm.screen_height = DisplayHeight(wm.dpy, wm.screen);
    
    // Validate screen dimensions
    if (wm.screen_width <= 0 || wm.screen_height <= 0) {
        fprintf(stderr, "VaultWM: Invalid screen dimensions: %dx%d\n", 
                wm.screen_width, wm.screen_height);
        XCloseDisplay(wm.dpy);
        exit(1);
    }
    
    wm.current_workspace = 0;
    wm.current_client = -1;
    wm.is_resizing = 0;
    wm.is_moving = 0;
    
    /* Initialize window rules */
    window_rules_init(&wm.window_rules);
    // Load rules from config file
    char rules_path[512];
    const char *home = getenv("HOME");
    if (home) {
        snprintf(rules_path, sizeof(rules_path), "%s/.config/vaultwm/rules", home);
        window_rules_load(rules_path, &wm.window_rules);
    }
    
    /* Initialize workspaces */
    int i;
    for (i = 0; i < MAX_WORKSPACES; i++) {
        wm.workspaces[i].num_clients = 0;
        wm.workspaces[i].layout_mode = 0;  // Start in tiling mode
    }

    /* Create status bar window */
    XSetWindowAttributes attrs;
    attrs.background_pixel = BLACK;
    attrs.override_redirect = True;
    attrs.event_mask = ExposureMask | ButtonPressMask;
    
    wm.status_bar = XCreateWindow(
        wm.dpy, wm.root,
        0, 0, wm.screen_width, STATUS_BAR_HEIGHT,
        0, DefaultDepth(wm.dpy, wm.screen),
        CopyFromParent, DefaultVisual(wm.dpy, wm.screen),
        CWBackPixel | CWOverrideRedirect | CWEventMask,
        &attrs
    );
    
    if (wm.status_bar == None) {
        fprintf(stderr, "VaultWM: Failed to create status bar window\n");
        XCloseDisplay(wm.dpy);
        exit(1);
    }
    
    if (XMapWindow(wm.dpy, wm.status_bar) == 0) {
        fprintf(stderr, "VaultWM: Failed to map status bar window\n");
        XDestroyWindow(wm.dpy, wm.status_bar);
        XCloseDisplay(wm.dpy);
        exit(1);
    }
    
    /* Create graphics context for status bar */
    XGCValues gc_vals;
    gc_vals.foreground = PIPBOY_GREEN;
    gc_vals.font = XLoadFont(wm.dpy, "fixed");
    
    if (gc_vals.font == None) {
        fprintf(stderr, "VaultWM: Warning: Failed to load font 'fixed', using default\n");
        gc_vals.font = XLoadFont(wm.dpy, "cursor");
    }
    
    wm.gc = XCreateGC(wm.dpy, wm.status_bar, GCForeground | GCFont, &gc_vals);
    if (wm.gc == None) {
        fprintf(stderr, "VaultWM: Failed to create graphics context\n");
        XDestroyWindow(wm.dpy, wm.status_bar);
        XCloseDisplay(wm.dpy);
        exit(1);
    }

    /* Set up atoms */
    wm.wm_protocols = XInternAtom(wm.dpy, "WM_PROTOCOLS", False);
    wm.wm_delete_window = XInternAtom(wm.dpy, "WM_DELETE_WINDOW", False);

    /* Select events */
    XSelectInput(wm.dpy, wm.root,
        SubstructureRedirectMask | SubstructureNotifyMask |
        ButtonPressMask | ButtonReleaseMask | KeyPressMask | PointerMotionMask);

    /* Grab keys - Basic */
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_Return),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_q),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_t),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_f),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_d),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    
    /* Navigation keys - Arrow keys */
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_Left),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_Right),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_Up),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_Down),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    
    /* Navigation keys - hjkl (vim-style) */
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_h),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_j),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_k),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_l),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    
    /* Workspace keys (1-9) */
    int key;
    for (key = XK_1; key <= XK_9; key++) {
        XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, key),
            Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    }
    
    /* Window management keys */
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_r),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_m),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);

    /* Set root window cursor */
    Cursor cursor = XCreateFontCursor(wm.dpy, XC_left_ptr);
    XDefineCursor(wm.dpy, wm.root, cursor);

    draw_status_bar();
}

void cleanup_wm(void) {
    if (!wm.dpy) {
        return;  // Already cleaned up or never initialized
    }
    
    // Clean up monitor manager
    monitor_cleanup(&wm.monitor_mgr);
    
    // Clean up window rules
    window_rules_cleanup(&wm.window_rules);
    
    // Clean up status bar
    if (wm.status_bar != None) {
        XDestroyWindow(wm.dpy, wm.status_bar);
        wm.status_bar = None;
    }
    
    // Free graphics context
    if (wm.gc != None) {
        XFreeGC(wm.dpy, wm.gc);
        wm.gc = None;
    }
    
    // Unmap and destroy all managed windows
    int i, j;
    for (i = 0; i < MAX_WORKSPACES; i++) {
        Workspace *ws = &wm.workspaces[i];
        for (j = 0; j < ws->num_clients; j++) {
            if (ws->clients[j].win != None) {
                XUnmapWindow(wm.dpy, ws->clients[j].win);
                XDestroyWindow(wm.dpy, ws->clients[j].win);
            }
        }
        ws->num_clients = 0;
    }
    
    // Close display
    XCloseDisplay(wm.dpy);
    wm.dpy = NULL;
}

/* Cached system information */
static int cached_mem_usage = -1;
static time_t mem_cache_time = 0;
#define MEM_CACHE_INTERVAL 2  // Cache for 2 seconds

/* Get system memory usage in percentage (cached) */
int get_memory_usage(void) {
    time_t now = time(NULL);
    
    // Return cached value if still valid
    if (cached_mem_usage >= 0 && (now - mem_cache_time) < MEM_CACHE_INTERVAL) {
        return cached_mem_usage;
    }
    
    FILE *meminfo = fopen("/proc/meminfo", "r");
    if (!meminfo) return (cached_mem_usage >= 0) ? cached_mem_usage : 0;
    
    unsigned long mem_total = 0, mem_free = 0, mem_available = 0;
    char line[128];
    
    while (fgets(line, sizeof(line), meminfo)) {
        if (sscanf(line, "MemTotal: %lu kB", &mem_total) == 1) continue;
        if (sscanf(line, "MemFree: %lu kB", &mem_free) == 1) continue;
        if (sscanf(line, "MemAvailable: %lu kB", &mem_available) == 1) break;
    }
    fclose(meminfo);
    
    if (mem_total == 0) return (cached_mem_usage >= 0) ? cached_mem_usage : 0;
    unsigned long mem_used = mem_total - mem_available;
    cached_mem_usage = (int)((mem_used * 100) / mem_total);
    mem_cache_time = now;
    return cached_mem_usage;
}

/* Cached CPU usage */
static int cached_cpu_usage = -1;
static time_t cpu_cache_time = 0;
static unsigned long long last_idle = 0, last_total = 0;
#define CPU_CACHE_INTERVAL 2  // Cache for 2 seconds

/* Get CPU usage (simple 1-second average, cached) */
int get_cpu_usage(void) {
    time_t now = time(NULL);
    
    // Return cached value if still valid
    if (cached_cpu_usage >= 0 && (now - cpu_cache_time) < CPU_CACHE_INTERVAL) {
        return cached_cpu_usage;
    }
    
    FILE *stat = fopen("/proc/stat", "r");
    if (!stat) return (cached_cpu_usage >= 0) ? cached_cpu_usage : 0;
    
    unsigned long long user = 0, nice = 0, system = 0, idle = 0;
    unsigned long long iowait = 0, irq = 0, softirq = 0;
    char cpu[16];
    char line[256];
    
    // Use fgets instead of fscanf for safer parsing
    if (fgets(line, sizeof(line), stat) == NULL) {
        fclose(stat);
        return (cached_cpu_usage >= 0) ? cached_cpu_usage : 0;
    }
    
    // Parse with sscanf and check return value
    int parsed = sscanf(line, "%15s %llu %llu %llu %llu %llu %llu %llu", 
                        cpu, &user, &nice, &system, &idle, &iowait, &irq, &softirq);
    fclose(stat);
    
    // Verify we parsed enough values
    if (parsed < 5) {
        return (cached_cpu_usage >= 0) ? cached_cpu_usage : 0;
    }
    
    unsigned long long total_idle = idle + iowait;
    unsigned long long total = user + nice + system + idle + iowait + irq + softirq;
    
    if (last_total == 0) {
        last_idle = total_idle;
        last_total = total;
        cached_cpu_usage = 0;
        cpu_cache_time = now;
        return 0;
    }
    
    unsigned long long idle_delta = total_idle - last_idle;
    unsigned long long total_delta = total - last_total;
    
    last_idle = total_idle;
    last_total = total;
    
    if (total_delta == 0) {
        cached_cpu_usage = (cached_cpu_usage >= 0) ? cached_cpu_usage : 0;
        cpu_cache_time = now;
        return cached_cpu_usage;
    }
    
    int usage = 100 - ((idle_delta * 100) / total_delta);
    cached_cpu_usage = (usage < 0) ? 0 : ((usage > 100) ? 100 : usage);
    cpu_cache_time = now;
    return cached_cpu_usage;
}

/* Cached network status */
static const char *cached_net_status = NULL;
static time_t net_cache_time = 0;
#define NET_CACHE_INTERVAL 5  // Cache for 5 seconds

/* Get network status (up/down, cached) */
const char* get_network_status(void) {
    time_t now = time(NULL);
    
    // Return cached value if still valid
    if (cached_net_status != NULL && (now - net_cache_time) < NET_CACHE_INTERVAL) {
        return cached_net_status;
    }
    
    FILE *route = fopen("/proc/net/route", "r");
    if (!route) {
        cached_net_status = "DOWN";
        net_cache_time = now;
        return cached_net_status;
    }
    
    char line[256];
    int has_default = 0;
    fgets(line, sizeof(line), route);  /* Skip header */
    while (fgets(line, sizeof(line), route)) {
        if (strstr(line, "00000000")) {
            has_default = 1;
            break;
        }
    }
    fclose(route);
    
    cached_net_status = has_default ? "UP" : "DOWN";
    net_cache_time = now;
    return cached_net_status;
}

void draw_status_bar(void) {
    char status[512];
    char time_str[64], date_str[64];
    time_t now;
    struct tm *timeinfo;
    
    /* Get current time */
    time(&now);
    timeinfo = localtime(&now);
    strftime(time_str, sizeof(time_str), "%H:%M:%S", timeinfo);
    strftime(date_str, sizeof(date_str), "%Y-%m-%d", timeinfo);
    
    /* Get system info */
    int cpu_usage = get_cpu_usage();
    int mem_usage = get_memory_usage();
    const char *net_status = get_network_status();
    
    /* Format status bar */
    Workspace *ws = current_workspace();
    const char *layout_name;
    switch (ws->layout_mode) {
        case LAYOUT_TILING: layout_name = "Tiling"; break;
        case LAYOUT_FLOATING: layout_name = "Floating"; break;
        case LAYOUT_MONOCLE: layout_name = "Monocle"; break;
        case LAYOUT_GRID: layout_name = "Grid"; break;
        case LAYOUT_FIBONACCI: layout_name = "Fibonacci"; break;
        case LAYOUT_DWINDLE: layout_name = "Dwindle"; break;
        default: layout_name = "Unknown"; break;
    }
    snprintf(status, sizeof(status), 
        "VaultOS | WS: %d | CPU: %d%% | MEM: %d%% | NET: %s | %s | %s | Clients: %d | Layout: %s | [Pip-Boy 3000]",
        wm.current_workspace + 1, cpu_usage, mem_usage, net_status, date_str, time_str, 
        ws->num_clients, layout_name);
    
    XClearWindow(wm.dpy, wm.status_bar);
    XDrawString(wm.dpy, wm.status_bar, wm.gc, 10, 20, status, strlen(status));
    XFlush(wm.dpy);
}

void update_status_bar(void) {
    draw_status_bar();
}

/* Get pointer to current workspace */
Workspace* current_workspace(void) {
    return &wm.workspaces[wm.current_workspace];
}

/* Switch to workspace */
void switch_workspace(int workspace) {
    if (workspace < 0 || workspace >= MAX_WORKSPACES) return;
    
    Workspace *old_ws = current_workspace();
    int i;
    
    /* Hide all windows in current workspace */
    for (i = 0; i < old_ws->num_clients; i++) {
        XUnmapWindow(wm.dpy, old_ws->clients[i].win);
    }
    
    /* Switch workspace */
    wm.current_workspace = workspace;
    wm.current_client = -1;
    
    /* Show all windows in new workspace */
    Workspace *new_ws = current_workspace();
    tile_windows();
    if (new_ws->num_clients > 0) {
        focus_client(0);
    }
    update_status_bar();
}

/* Focus next window */
void focus_next(void) {
    Workspace *ws = current_workspace();
    if (ws->num_clients == 0) return;
    int next = (wm.current_client + 1) % ws->num_clients;
    focus_client(next);
}

/* Focus previous window */
void focus_prev(void) {
    Workspace *ws = current_workspace();
    if (ws->num_clients == 0) return;
    int prev = (wm.current_client - 1 + ws->num_clients) % ws->num_clients;
    focus_client(prev);
}

/* Validate command path - check if executable exists and is safe */
static int is_valid_executable(const char *path) {
    struct stat st;
    
    if (!path || path[0] == '\0') {
        return 0;
    }
    
    // Check for absolute path
    if (path[0] != '/') {
        return 0;  // Only allow absolute paths for security
    }
    
    // Check if file exists and is executable
    if (stat(path, &st) != 0) {
        return 0;
    }
    
    // Check if it's a regular file
    if (!S_ISREG(st.st_mode)) {
        return 0;
    }
    
    // Check if executable by owner
    if (!(st.st_mode & S_IXUSR)) {
        return 0;
    }
    
    return 1;
}

/* Validate command string - no dangerous characters */
static int is_safe_command(const char *cmd) {
    size_t i;
    int has_whitespace = 0;
    
    if (!cmd || cmd[0] == '\0') {
        return 0;
    }
    
    // Check for dangerous characters
    for (i = 0; cmd[i] != '\0'; i++) {
        // Allow alphanumeric, spaces, slashes, dashes, underscores, dots, colons
        if (!isalnum(cmd[i]) && 
            cmd[i] != ' ' && cmd[i] != '/' && cmd[i] != '-' && 
            cmd[i] != '_' && cmd[i] != '.' && cmd[i] != ':' &&
            cmd[i] != '|' && cmd[i] != '&' && cmd[i] != ';') {
            // Check for shell redirection and other dangerous patterns
            if (cmd[i] == '<' || cmd[i] == '>' || cmd[i] == '`' || 
                cmd[i] == '$' || cmd[i] == '(' || cmd[i] == ')') {
                return 0;  // Dangerous shell characters
            }
        }
        if (cmd[i] == ' ') {
            has_whitespace = 1;
        }
    }
    
    // For commands with || (fallback), validate both parts
    if (strstr(cmd, " || ") != NULL) {
        char cmd_copy[512];
        char *part1, *part2, *saveptr;
        
        strncpy(cmd_copy, cmd, sizeof(cmd_copy) - 1);
        cmd_copy[sizeof(cmd_copy) - 1] = '\0';
        
        part1 = strtok_r(cmd_copy, "|", &saveptr);
        part2 = strtok_r(NULL, "|", &saveptr);
        
        if (part1 && part2) {
            // Trim whitespace
            while (*part1 == ' ') part1++;
            while (*part2 == ' ') part2++;
            
            // Validate both parts
            if (!is_safe_command(part1) || !is_safe_command(part2)) {
                return 0;
            }
        }
    }
    
    return 1;
}

/* Launch application with security validation */
void launch_application(const char *cmd) {
    pid_t pid;
    
    if (!cmd || cmd[0] == '\0') {
        fprintf(stderr, "VaultWM: Empty command\n");
        return;
    }
    
    // Validate command safety
    if (!is_safe_command(cmd)) {
        fprintf(stderr, "VaultWM: Unsafe command rejected: %s\n", cmd);
        return;
    }
    
    // For simple commands (no shell), validate executable path
    if (strstr(cmd, " || ") == NULL && strstr(cmd, " ") == NULL) {
        if (!is_valid_executable(cmd)) {
            fprintf(stderr, "VaultWM: Invalid executable: %s\n", cmd);
            return;
        }
    }
    
    pid = fork();
    if (pid < 0) {
        fprintf(stderr, "VaultWM: Failed to fork: %s\n", strerror(errno));
        return;
    }
    
    if (pid == 0) {
        // Child process
        setsid();
        
        // Use execvp for better security (searches PATH safely)
        // For commands with || fallback, we need shell
        if (strstr(cmd, " || ") != NULL) {
            execl("/bin/sh", "sh", "-c", cmd, NULL);
        } else {
            // Parse command into arguments
            char *cmd_copy = strdup(cmd);
            char *argv[64];
            int argc = 0;
            char *token = strtok(cmd_copy, " ");
            
            while (token && argc < 63) {
                argv[argc++] = token;
                token = strtok(NULL, " ");
            }
            argv[argc] = NULL;
            
            execvp(argv[0], argv);
            free(cmd_copy);
        }
        
        // If we get here, exec failed
        fprintf(stderr, "VaultWM: Failed to execute: %s\n", cmd);
        exit(1);
    }
    
    // Parent process - don't wait for child (non-blocking)
}

void manage_window(Window w) {
    Workspace *ws = current_workspace();
    if (!ws) {
        fprintf(stderr, "VaultWM: Invalid workspace in manage_window\n");
        return;
    }
    
    if (ws->num_clients >= MAX_WINDOWS) {
        fprintf(stderr, "VaultWM: Maximum window limit reached (%d)\n", MAX_WINDOWS);
        return;
    }

    XWindowAttributes wa;
    if (XGetWindowAttributes(wm.dpy, w, &wa) == 0) {
        fprintf(stderr, "VaultWM: Failed to get window attributes for window 0x%lx\n", w);
        return;
    }

    // Get window class and instance for rules
    XClassHint class_hint;
    char class_name[256] = "";
    char instance_name[256] = "";
    
    if (XGetClassHint(wm.dpy, w, &class_hint)) {
        if (class_hint.res_class) {
            strncpy(class_name, class_hint.res_class, sizeof(class_name) - 1);
            class_name[sizeof(class_name) - 1] = '\0';
        }
        if (class_hint.res_name) {
            strncpy(instance_name, class_hint.res_name, sizeof(instance_name) - 1);
            instance_name[sizeof(instance_name) - 1] = '\0';
        }
        if (class_hint.res_class) XFree(class_hint.res_class);
        if (class_hint.res_name) XFree(class_hint.res_name);
    }

    Client *c = &ws->clients[ws->num_clients];
    c->win = w;
    c->is_floating = 0;  // Default to tiling
    c->is_mapped = 1;
    c->x = 0;
    c->y = 0;
    c->width = wa.width;
    c->height = wa.height;

    // Apply window rules
    window_rules_apply(&wm.window_rules, w, class_name, instance_name);
    
    // Check if rule set window to floating (simplified - full implementation would parse rule value)
    // For now, we'll check common floating applications
    if (strstr(class_name, "Gimp") || strstr(class_name, "Gimp") ||
        strstr(class_name, "Pidgin") || strstr(class_name, "Pidgin")) {
        c->is_floating = 1;
    }

    /* Set border */
    XSetWindowBorderWidth(wm.dpy, w, BORDER_WIDTH);
    XSetWindowBorder(wm.dpy, w, PIPBOY_GREEN);

    /* Set event mask */
    XSelectInput(wm.dpy, w,
        StructureNotifyMask | EnterWindowMask | LeaveWindowMask |
        FocusChangeMask | PropertyChangeMask | ButtonPressMask | ButtonMotionMask);

    /* Set protocols */
    Atom protocols[] = {wm.wm_delete_window};
    Status status = XSetWMProtocols(wm.dpy, w, protocols, 1);
    if (status == 0) {
        fprintf(stderr, "VaultWM: Warning: Failed to set WM protocols for window 0x%lx\n", w);
    }

    ws->num_clients++;
    tile_windows();
    if (ws->num_clients > 0) {
        focus_client(ws->num_clients - 1);
    }
    update_status_bar();
}

void unmanage_window(Window w) {
    Workspace *ws = current_workspace();
    int i;
    for (i = 0; i < ws->num_clients; i++) {
        if (ws->clients[i].win == w) {
            /* Remove from array */
            memmove(&ws->clients[i], &ws->clients[i + 1],
                (ws->num_clients - i - 1) * sizeof(Client));
            ws->num_clients--;
            if (wm.current_client >= ws->num_clients) {
                wm.current_client = ws->num_clients - 1;
            }
            tile_windows();
            update_status_bar();
            return;
        }
    }
}

void tile_windows(void) {
    Workspace *ws = current_workspace();
    if (ws->num_clients == 0) return;

    int usable_height = wm.screen_height - STATUS_BAR_HEIGHT - (WINDOW_GAP * 2);
    int usable_width = wm.screen_width - (WINDOW_GAP * 2);
    int y = STATUS_BAR_HEIGHT + WINDOW_GAP;
    
    if (ws->layout_mode == 0) {
        /* Tiling layout */
        int height = usable_height / ws->num_clients;
        int i;
        for (i = 0; i < ws->num_clients; i++) {
            if (!ws->clients[i].is_floating) {
                XMoveResizeWindow(wm.dpy, ws->clients[i].win,
                    WINDOW_GAP, y, usable_width, height - WINDOW_GAP);
                ws->clients[i].x = WINDOW_GAP;
                ws->clients[i].y = y;
                ws->clients[i].width = usable_width;
                ws->clients[i].height = height - WINDOW_GAP;
                y += height;
            }
        }
    } else if (ws->layout_mode == 2) {
        /* Monocle layout - fullscreen */
        int i;
        for (i = 0; i < ws->num_clients; i++) {
            if (!ws->clients[i].is_floating && i == wm.current_client) {
                XMoveResizeWindow(wm.dpy, ws->clients[i].win,
                    0, STATUS_BAR_HEIGHT, wm.screen_width, usable_height);
                ws->clients[i].x = 0;
                ws->clients[i].y = STATUS_BAR_HEIGHT;
                ws->clients[i].width = wm.screen_width;
                ws->clients[i].height = usable_height;
            } else if (!ws->clients[i].is_floating) {
                XUnmapWindow(wm.dpy, ws->clients[i].win);
            }
        }
    }
    /* Floating layout - windows manage their own position */
}

void focus_client(int index) {
    Workspace *ws = current_workspace();
    if (!ws) {
        fprintf(stderr, "VaultWM: Invalid workspace in focus_client\n");
        return;
    }
    
    if (index < 0 || index >= ws->num_clients) {
        fprintf(stderr, "VaultWM: Invalid client index %d (max: %d)\n", index, ws->num_clients);
        return;
    }
    
    /* Unfocus previous client */
    if (wm.current_client >= 0 && wm.current_client < ws->num_clients) {
        if (ws->clients[wm.current_client].win != None) {
            XSetWindowBorder(wm.dpy, ws->clients[wm.current_client].win, DARK_GREEN);
        }
    }
    
    wm.current_client = index;
    
    if (ws->clients[index].win == None) {
        fprintf(stderr, "VaultWM: Invalid window in focus_client\n");
        return;
    }
    
    XRaiseWindow(wm.dpy, ws->clients[index].win);
    XSetInputFocus(wm.dpy, ws->clients[index].win, RevertToPointerRoot, CurrentTime);
    XSetWindowBorder(wm.dpy, ws->clients[index].win, PIPBOY_GREEN);
    tile_windows();  /* Update layout for monocle */
    update_status_bar();
}

void handle_keypress(XKeyEvent *e) {
    if (e->state != Mod4Mask) return;
    
    Workspace *ws = current_workspace();
    KeyCode keycode = e->keycode;

    if (keycode == XKeysymToKeycode(wm.dpy, XK_Return)) {
        /* Launch terminal */
        launch_application(TERMINAL_CMD " || " TERMINAL_FALLBACK);
    } else if (keycode == XKeysymToKeycode(wm.dpy, XK_d)) {
        /* Launch application launcher */
        launch_application(LAUNCHER_CMD " || " LAUNCHER_FALLBACK);
    } else if (keycode == XKeysymToKeycode(wm.dpy, XK_q)) {
        /* Quit focused window */
        if (wm.current_client >= 0 && wm.current_client < ws->num_clients) {
            XEvent ev;
            ev.xclient.type = ClientMessage;
            ev.xclient.window = ws->clients[wm.current_client].win;
            ev.xclient.message_type = wm.wm_protocols;
            ev.xclient.format = 32;
            ev.xclient.data.l[0] = wm.wm_delete_window;
            ev.xclient.data.l[1] = CurrentTime;
            XSendEvent(wm.dpy, ws->clients[wm.current_client].win, False, NoEventMask, &ev);
        }
    } else if (keycode == XKeysymToKeycode(wm.dpy, XK_t)) {
        /* Toggle layout: Tiling -> Floating -> Monocle */
        ws->layout_mode = (ws->layout_mode + 1) % 6;  // Cycle through all layouts
        tile_windows();
        update_status_bar();
    } else if (keycode == XKeysymToKeycode(wm.dpy, XK_f)) {
        /* Toggle floating for current window */
        if (wm.current_client >= 0 && wm.current_client < ws->num_clients) {
            ws->clients[wm.current_client].is_floating = 
                !ws->clients[wm.current_client].is_floating;
            tile_windows();
        }
    } else if (keycode == XKeysymToKeycode(wm.dpy, XK_Left) || 
               keycode == XKeysymToKeycode(wm.dpy, XK_h)) {
        /* Focus previous window */
        focus_prev();
    } else if (keycode == XKeysymToKeycode(wm.dpy, XK_Right) || 
               keycode == XKeysymToKeycode(wm.dpy, XK_l)) {
        /* Focus next window */
        focus_next();
    } else if (keycode >= XKeysymToKeycode(wm.dpy, XK_1) && 
               keycode <= XKeysymToKeycode(wm.dpy, XK_9)) {
        /* Switch workspace (1-9) */
        int workspace = keycode - XKeysymToKeycode(wm.dpy, XK_1);
        switch_workspace(workspace);
    } else if (keycode == XKeysymToKeycode(wm.dpy, XK_r)) {
        /* Enter resize mode */
        wm.is_resizing = 1;
    } else if (keycode == XKeysymToKeycode(wm.dpy, XK_m)) {
        /* Enter move mode */
        wm.is_moving = 1;
    }
}

void handle_configure_request(XConfigureRequestEvent *e) {
    XWindowChanges wc;
    wc.x = e->x;
    wc.y = e->y;
    wc.width = e->width;
    wc.height = e->height;
    wc.border_width = e->border_width;
    wc.sibling = e->above;
    wc.stack_mode = e->detail;
    XConfigureWindow(wm.dpy, e->window, e->value_mask, &wc);
    XSync(wm.dpy, False);
}

void handle_map_request(XMapRequestEvent *e) {
    manage_window(e->window);
    XMapWindow(wm.dpy, e->window);
}

void handle_unmap_notify(XUnmapEvent *e) {
    unmanage_window(e->window);
}

void handle_motion_notify(XMotionEvent *e) {
    Workspace *ws = current_workspace();
    if (wm.is_resizing && wm.current_client >= 0 && wm.current_client < ws->num_clients) {
        Client *c = &ws->clients[wm.current_client];
        int dx = e->x_root - wm.resize_start_x;
        int dy = e->y_root - wm.resize_start_y;
        XResizeWindow(wm.dpy, c->win, c->width + dx, c->height + dy);
        c->width += dx;
        c->height += dy;
        wm.resize_start_x = e->x_root;
        wm.resize_start_y = e->y_root;
    } else if (wm.is_moving && wm.current_client >= 0 && wm.current_client < ws->num_clients) {
        Client *c = &ws->clients[wm.current_client];
        int dx = e->x_root - wm.move_start_x;
        int dy = e->y_root - wm.move_start_y;
        XMoveWindow(wm.dpy, c->win, c->x + dx, c->y + dy);
        c->x += dx;
        c->y += dy;
        wm.move_start_x = e->x_root;
        wm.move_start_y = e->y_root;
    }
}

void handle_buttonpress(XButtonEvent *e) {
    if (e->button == Button1 && e->state == Mod4Mask) {
        /* Start moving window */
        Window child;
        int root_x, root_y, win_x, win_y;
        unsigned int mask;
        XQueryPointer(wm.dpy, wm.root, &child, &child, &root_x, &root_y, &win_x, &win_y, &mask);
        wm.is_moving = 1;
        wm.move_start_x = root_x;
        wm.move_start_y = root_y;
        Workspace *ws = current_workspace();
        if (wm.current_client >= 0 && wm.current_client < ws->num_clients) {
            Client *c = &ws->clients[wm.current_client];
            c->is_floating = 1;
        }
    } else if (e->button == Button3 && e->state == Mod4Mask) {
        /* Start resizing window */
        Window child;
        int root_x, root_y, win_x, win_y;
        unsigned int mask;
        XQueryPointer(wm.dpy, wm.root, &child, &child, &root_x, &root_y, &win_x, &win_y, &mask);
        wm.is_resizing = 1;
        wm.resize_start_x = root_x;
        wm.resize_start_y = root_y;
        Workspace *ws = current_workspace();
        if (wm.current_client >= 0 && wm.current_client < ws->num_clients) {
            Client *c = &ws->clients[wm.current_client];
            c->is_floating = 1;
        }
    }
}

void handle_event(XEvent *e) {
    switch (e->type) {
        case KeyPress:
            handle_keypress(&e->xkey);
            break;
        case KeyRelease:
            /* Exit resize/move mode */
            if (e->xkey.keycode == XKeysymToKeycode(wm.dpy, XK_r) ||
                e->xkey.keycode == XKeysymToKeycode(wm.dpy, XK_m)) {
                wm.is_resizing = 0;
                wm.is_moving = 0;
            }
            break;
        case ButtonPress:
            handle_buttonpress(&e->xbutton);
            break;
        case ButtonRelease:
            wm.is_resizing = 0;
            wm.is_moving = 0;
            break;
        case MotionNotify:
            handle_motion_notify(&e->xmotion);
            break;
        case ConfigureRequest:
            handle_configure_request(&e->xconfigurerequest);
            break;
        case MapRequest:
            handle_map_request(&e->xmaprequest);
            break;
        case UnmapNotify:
            handle_unmap_notify(&e->xunmap);
            break;
        case Expose:
            if (e->xexpose.window == wm.status_bar) {
                draw_status_bar();
            }
            break;
    }
}

int main(void) {
    setup_wm();

    XEvent ev;
    time_t last_status_update = 0;
    
    while (1) {
        /* Check for X events with timeout for status bar updates */
        fd_set fds;
        struct timeval tv;
        int x_fd = ConnectionNumber(wm.dpy);
        
        FD_ZERO(&fds);
        FD_SET(x_fd, &fds);
        tv.tv_sec = 0;
        tv.tv_usec = 500000;  /* 0.5 second timeout */
        
        int ret = select(x_fd + 1, &fds, NULL, NULL, &tv);
        
        if (ret > 0 && FD_ISSET(x_fd, &fds)) {
            /* X event available */
            while (XPending(wm.dpy)) {
                XNextEvent(wm.dpy, &ev);
                handle_event(&ev);
            }
        }
        
        /* Update status bar every second */
        time_t now = time(NULL);
        if (now != last_status_update) {
            update_status_bar();
            last_status_update = now;
        }
    }

    cleanup_wm();
    return 0;
}

