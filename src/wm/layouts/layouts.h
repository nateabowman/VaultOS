/*
 * VaultWM Advanced Layout Algorithms
 * Grid, Fibonacci, and Dwindle layouts
 */

#ifndef VAULTWM_LAYOUTS_H
#define VAULTWM_LAYOUTS_H

#include <X11/Xlib.h>

#define LAYOUT_TILING 0
#define LAYOUT_FLOATING 1
#define LAYOUT_MONOCLE 2
#define LAYOUT_GRID 3
#define LAYOUT_FIBONACCI 4
#define LAYOUT_DWINDLE 5

typedef struct {
    Window win;
    int x, y, width, height;
    int is_floating;
} LayoutClient;

/* Grid layout - arrange windows in a grid */
void layout_grid(LayoutClient *clients, int num_clients, int x, int y, int width, int height, int gap);

/* Fibonacci layout - spiral arrangement */
void layout_fibonacci(LayoutClient *clients, int num_clients, int x, int y, int width, int height, int gap);

/* Dwindle layout - binary tree arrangement */
void layout_dwindle(LayoutClient *clients, int num_clients, int x, int y, int width, int height, int gap);

#endif /* VAULTWM_LAYOUTS_H */

