/*
 * VaultWM Backend Abstraction Layer
 * Provides unified interface for X11 and Wayland backends
 */

#ifndef VAULTWM_BACKEND_H
#define VAULTWM_BACKEND_H

#include <stdint.h>

/* Forward declarations */
typedef struct Window Window;
typedef struct Display Display;

/* Backend types */
typedef enum {
    BACKEND_X11,
    BACKEND_WAYLAND,
    BACKEND_UNKNOWN
} BackendType;

/* Window structure (opaque) */
struct Window {
    void *native_handle;  // X11 Window or wl_surface
    BackendType backend;
};

/* Display structure (opaque) */
struct Display {
    void *native_handle;  // X11 Display or wl_display
    BackendType backend;
};

/* Backend operations */
typedef struct {
    /* Initialization */
    int (*init)(Display **dpy);
    void (*cleanup)(Display *dpy);
    
    /* Window operations */
    int (*create_window)(Display *dpy, Window **win, int x, int y, int w, int h);
    void (*destroy_window)(Display *dpy, Window *win);
    void (*resize_window)(Display *dpy, Window *win, int w, int h);
    void (*move_window)(Display *dpy, Window *win, int x, int y);
    void (*map_window)(Display *dpy, Window *win);
    void (*unmap_window)(Display *dpy, Window *win);
    
    /* Focus and input */
    void (*focus_window)(Display *dpy, Window *win);
    void (*set_input_focus)(Display *dpy, Window *win);
    
    /* Properties */
    void (*set_border)(Display *dpy, Window *win, uint32_t color, int width);
    void (*set_title)(Display *dpy, Window *win, const char *title);
    
    /* Events */
    int (*wait_event)(Display *dpy, void *event);
    int (*pending_events)(Display *dpy);
    
    /* Monitor/Output */
    int (*get_screen_size)(Display *dpy, int *w, int *h);
    int (*get_monitor_count)(Display *dpy);
    
    /* Backend info */
    BackendType type;
    const char *name;
} WMBackend;

/* Get backend for protocol */
WMBackend* backend_get_x11(void);
WMBackend* backend_get_wayland(void);

/* Detect and initialize backend */
WMBackend* backend_detect_and_init(Display **dpy);

/* Get current backend */
WMBackend* backend_get_current(void);

#endif /* VAULTWM_BACKEND_H */

