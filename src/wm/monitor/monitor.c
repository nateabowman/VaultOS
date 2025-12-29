/*
 * VaultWM Multi-Monitor Implementation
 * Uses XRandR for monitor detection
 */

#include <X11/Xlib.h>
#include <X11/extensions/Xrandr.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "monitor.h"

int monitor_init(Display *dpy, MonitorManager *mm) {
    int event_base, error_base;
    XRRScreenResources *resources;
    XRROutputInfo *output_info;
    XRRCrtcInfo *crtc_info;
    int i;
    
    if (!XRRQueryExtension(dpy, &event_base, &error_base)) {
        // XRandR not available, use single monitor
        mm->num_monitors = 1;
        mm->monitors[0].x = 0;
        mm->monitors[0].y = 0;
        mm->monitors[0].width = DisplayWidth(dpy, DefaultScreen(dpy));
        mm->monitors[0].height = DisplayHeight(dpy, DefaultScreen(dpy));
        mm->monitors[0].primary = 1;
        mm->monitors[0].root = RootWindow(dpy, DefaultScreen(dpy));
        strncpy(mm->monitors[0].name, "Default", sizeof(mm->monitors[0].name) - 1);
        mm->primary_monitor = 0;
        return 1;
    }
    
    // Get screen resources
    resources = XRRGetScreenResources(dpy, RootWindow(dpy, DefaultScreen(dpy)));
    if (!resources) {
        return 0;
    }
    
    mm->num_monitors = 0;
    mm->primary_monitor = 0;
    
    // Enumerate outputs
    for (i = 0; i < resources->noutput && mm->num_monitors < MAX_MONITORS; i++) {
        output_info = XRRGetOutputInfo(dpy, resources, resources->outputs[i]);
        if (!output_info || output_info->connection != RR_Connected) {
            if (output_info) XRRFreeOutputInfo(output_info);
            continue;
        }
        
        if (output_info->crtc != None) {
            crtc_info = XRRGetCrtcInfo(dpy, resources, output_info->crtc);
            if (crtc_info) {
                Monitor *mon = &mm->monitors[mm->num_monitors];
                mon->x = crtc_info->x;
                mon->y = crtc_info->y;
                mon->width = crtc_info->width;
                mon->height = crtc_info->height;
                mon->primary = (output_info->crtc == resources->outputs[0]) ? 1 : 0;
                mon->root = RootWindow(dpy, DefaultScreen(dpy));
                
                strncpy(mon->name, output_info->name, sizeof(mon->name) - 1);
                mon->name[sizeof(mon->name) - 1] = '\0';
                
                if (mon->primary) {
                    mm->primary_monitor = mm->num_monitors;
                }
                
                mm->num_monitors++;
                XRRFreeCrtcInfo(crtc_info);
            }
        }
        
        XRRFreeOutputInfo(output_info);
    }
    
    XRRFreeScreenResources(resources);
    
    if (mm->num_monitors == 0) {
        // Fallback to single monitor
        mm->num_monitors = 1;
        mm->monitors[0].x = 0;
        mm->monitors[0].y = 0;
        mm->monitors[0].width = DisplayWidth(dpy, DefaultScreen(dpy));
        mm->monitors[0].height = DisplayHeight(dpy, DefaultScreen(dpy));
        mm->monitors[0].primary = 1;
        mm->monitors[0].root = RootWindow(dpy, DefaultScreen(dpy));
        strncpy(mm->monitors[0].name, "Default", sizeof(mm->monitors[0].name) - 1);
        mm->primary_monitor = 0;
    }
    
    return 1;
}

int monitor_count(MonitorManager *mm) {
    return mm ? mm->num_monitors : 0;
}

Monitor* monitor_get_primary(MonitorManager *mm) {
    if (!mm || mm->num_monitors == 0) {
        return NULL;
    }
    return &mm->monitors[mm->primary_monitor];
}

Monitor* monitor_at_point(MonitorManager *mm, int x, int y) {
    int i;
    
    if (!mm || mm->num_monitors == 0) {
        return NULL;
    }
    
    // Find monitor containing point
    for (i = 0; i < mm->num_monitors; i++) {
        Monitor *mon = &mm->monitors[i];
        if (x >= mon->x && x < mon->x + mon->width &&
            y >= mon->y && y < mon->y + mon->height) {
            return mon;
        }
    }
    
    // Fallback to primary
    return monitor_get_primary(mm);
}

Monitor* monitor_for_window(MonitorManager *mm, Window win) {
    // For now, return primary monitor
    // In full implementation, would query window position
    return monitor_get_primary(mm);
}

void monitor_update(Display *dpy, MonitorManager *mm) {
    // Reinitialize to get updated configuration
    monitor_init(dpy, mm);
}

void monitor_cleanup(MonitorManager *mm) {
    if (mm) {
        mm->num_monitors = 0;
        mm->primary_monitor = 0;
    }
}

