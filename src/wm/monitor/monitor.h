/*
 * VaultWM Multi-Monitor Support
 * Monitor detection and management using XRandR
 */

#ifndef VAULTWM_MONITOR_H
#define VAULTWM_MONITOR_H

#include <X11/Xlib.h>

#define MAX_MONITORS 8

typedef struct {
    int x, y;
    int width, height;
    int primary;
    char name[64];
    Window root;
} Monitor;

typedef struct {
    Monitor monitors[MAX_MONITORS];
    int num_monitors;
    int primary_monitor;
} MonitorManager;

/* Initialize monitor manager */
int monitor_init(Display *dpy, MonitorManager *mm);

/* Get monitor count */
int monitor_count(MonitorManager *mm);

/* Get primary monitor */
Monitor* monitor_get_primary(MonitorManager *mm);

/* Get monitor at point */
Monitor* monitor_at_point(MonitorManager *mm, int x, int y);

/* Get monitor for window */
Monitor* monitor_for_window(MonitorManager *mm, Window win);

/* Update monitor configuration */
void monitor_update(Display *dpy, MonitorManager *mm);

/* Cleanup monitor manager */
void monitor_cleanup(MonitorManager *mm);

#endif /* VAULTWM_MONITOR_H */

