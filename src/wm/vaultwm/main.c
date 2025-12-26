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

#define MAX_WINDOWS 256
#define STATUS_BAR_HEIGHT 30
#define BORDER_WIDTH 2
#define PIPBOY_GREEN 0x00FF41
#define BLACK 0x000000
#define DARK_GREEN 0x003300

typedef struct {
    Window win;
    int x, y, width, height;
    int is_floating;
    int is_mapped;
} Client;

typedef struct {
    Display *dpy;
    Window root;
    int screen;
    int screen_width, screen_height;
    Client clients[MAX_WINDOWS];
    int num_clients;
    int current_client;
    int layout_mode;  // 0 = tiling, 1 = floating
    Window status_bar;
    GC gc;
    Atom wm_protocols;
    Atom wm_delete_window;
} VaultWM;

VaultWM wm;

/* Forward declarations */
void setup_wm(void);
void cleanup_wm(void);
void handle_event(XEvent *e);
void handle_keypress(XKeyEvent *e);
void handle_buttonpress(XButtonEvent *e);
void handle_configure_request(XConfigureRequestEvent *e);
void handle_map_request(XMapRequestEvent *e);
void handle_unmap_notify(XUnmapEvent *e);
void manage_window(Window w);
void unmanage_window(Window w);
void tile_windows(void);
void draw_status_bar(void);
void update_status_bar(void);
void focus_client(int index);
void move_client(int index, int dx, int dy);
void resize_client(int index, int dw, int dh);

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
    wm.num_clients = 0;
    wm.current_client = -1;
    wm.layout_mode = 0;  // Start in tiling mode

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
    
    XMapWindow(wm.dpy, wm.status_bar);
    
    /* Create graphics context for status bar */
    XGCValues gc_vals;
    gc_vals.foreground = PIPBOY_GREEN;
    gc_vals.font = XLoadFont(wm.dpy, "fixed");
    wm.gc = XCreateGC(wm.dpy, wm.status_bar, GCForeground | GCFont, &gc_vals);

    /* Set up atoms */
    wm.wm_protocols = XInternAtom(wm.dpy, "WM_PROTOCOLS", False);
    wm.wm_delete_window = XInternAtom(wm.dpy, "WM_DELETE_WINDOW", False);

    /* Select events */
    XSelectInput(wm.dpy, wm.root,
        SubstructureRedirectMask | SubstructureNotifyMask |
        ButtonPressMask | KeyPressMask | PointerMotionMask);

    /* Grab keys */
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_Return),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_q),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_t),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);
    XGrabKey(wm.dpy, XKeysymToKeycode(wm.dpy, XK_f),
        Mod4Mask, wm.root, True, GrabModeAsync, GrabModeAsync);

    /* Set root window cursor */
    Cursor cursor = XCreateFontCursor(wm.dpy, XC_left_ptr);
    XDefineCursor(wm.dpy, wm.root, cursor);

    draw_status_bar();
}

void cleanup_wm(void) {
    XCloseDisplay(wm.dpy);
}

void draw_status_bar(void) {
    char status[256];
    snprintf(status, sizeof(status), "VaultOS | Clients: %d | Layout: %s | [Pip-Boy 3000]",
        wm.num_clients, wm.layout_mode == 0 ? "Tiling" : "Floating");
    
    XClearWindow(wm.dpy, wm.status_bar);
    XDrawString(wm.dpy, wm.status_bar, wm.gc, 10, 20, status, strlen(status));
    XFlush(wm.dpy);
}

void update_status_bar(void) {
    draw_status_bar();
}

void manage_window(Window w) {
    if (wm.num_clients >= MAX_WINDOWS) return;

    XWindowAttributes wa;
    XGetWindowAttributes(wm.dpy, w, &wa);

    Client *c = &wm.clients[wm.num_clients];
    c->win = w;
    c->is_floating = 0;
    c->is_mapped = 1;

    /* Set border */
    XSetWindowBorderWidth(wm.dpy, w, BORDER_WIDTH);
    XSetWindowBorder(wm.dpy, w, PIPBOY_GREEN);

    /* Set event mask */
    XSelectInput(wm.dpy, w,
        StructureNotifyMask | EnterWindowMask | LeaveWindowMask |
        FocusChangeMask | PropertyChangeMask | ButtonPressMask);

    /* Set protocols */
    Atom protocols[] = {wm.wm_delete_window};
    XSetWMProtocols(wm.dpy, w, protocols, 1);

    wm.num_clients++;
    tile_windows();
    focus_client(wm.num_clients - 1);
    update_status_bar();
}

void unmanage_window(Window w) {
    int i;
    for (i = 0; i < wm.num_clients; i++) {
        if (wm.clients[i].win == w) {
            /* Remove from array */
            memmove(&wm.clients[i], &wm.clients[i + 1],
                (wm.num_clients - i - 1) * sizeof(Client));
            wm.num_clients--;
            if (wm.current_client >= wm.num_clients) {
                wm.current_client = wm.num_clients - 1;
            }
            tile_windows();
            update_status_bar();
            return;
        }
    }
}

void tile_windows(void) {
    if (wm.num_clients == 0) return;

    int y = STATUS_BAR_HEIGHT;
    int height = (wm.screen_height - STATUS_BAR_HEIGHT) / wm.num_clients;
    int i;

    for (i = 0; i < wm.num_clients; i++) {
        if (!wm.clients[i].is_floating) {
            XMoveResizeWindow(wm.dpy, wm.clients[i].win,
                0, y, wm.screen_width, height);
            wm.clients[i].x = 0;
            wm.clients[i].y = y;
            wm.clients[i].width = wm.screen_width;
            wm.clients[i].height = height;
            y += height;
        }
    }
}

void focus_client(int index) {
    if (index < 0 || index >= wm.num_clients) return;
    
    wm.current_client = index;
    XSetInputFocus(wm.dpy, wm.clients[index].win, RevertToPointerRoot, CurrentTime);
    XSetWindowBorder(wm.dpy, wm.clients[index].win, PIPBOY_GREEN);
    update_status_bar();
}

void handle_keypress(XKeyEvent *e) {
    if (e->state != Mod4Mask) return;

    if (e->keycode == XKeysymToKeycode(wm.dpy, XK_Return)) {
        /* Launch terminal */
        if (fork() == 0) {
            execl("/usr/bin/alacritty", "alacritty", NULL);
            execl("/usr/bin/xterm", "xterm", NULL);
            exit(1);
        }
    } else if (e->keycode == XKeysymToKeycode(wm.dpy, XK_q)) {
        /* Quit focused window */
        if (wm.current_client >= 0) {
            XEvent ev;
            ev.xclient.type = ClientMessage;
            ev.xclient.window = wm.clients[wm.current_client].win;
            ev.xclient.message_type = wm.wm_protocols;
            ev.xclient.format = 32;
            ev.xclient.data.l[0] = wm.wm_delete_window;
            ev.xclient.data.l[1] = CurrentTime;
            XSendEvent(wm.dpy, wm.clients[wm.current_client].win, False, NoEventMask, &ev);
        }
    } else if (e->keycode == XKeysymToKeycode(wm.dpy, XK_t)) {
        /* Toggle layout */
        wm.layout_mode = !wm.layout_mode;
        tile_windows();
        update_status_bar();
    } else if (e->keycode == XKeysymToKeycode(wm.dpy, XK_f)) {
        /* Toggle floating for current window */
        if (wm.current_client >= 0) {
            wm.clients[wm.current_client].is_floating = 
                !wm.clients[wm.current_client].is_floating;
            tile_windows();
        }
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

void handle_event(XEvent *e) {
    switch (e->type) {
        case KeyPress:
            handle_keypress(&e->xkey);
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
    while (1) {
        XNextEvent(wm.dpy, &ev);
        handle_event(&ev);
    }

    cleanup_wm();
    return 0;
}

