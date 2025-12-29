/*
 * VaultWM Advanced Layout Algorithms Implementation
 */

#include <math.h>
#include <stdlib.h>
#include "layouts.h"

/* Grid layout - divide screen into equal cells */
void layout_grid(LayoutClient *clients, int num_clients, int x, int y, int width, int height, int gap) {
    if (num_clients == 0) return;
    
    int cols = (int)ceil(sqrt(num_clients));
    int rows = (int)ceil((double)num_clients / cols);
    int cell_width = (width - (gap * (cols + 1))) / cols;
    int cell_height = (height - (gap * (rows + 1))) / rows;
    
    int i;
    for (i = 0; i < num_clients; i++) {
        if (clients[i].is_floating) continue;
        
        int col = i % cols;
        int row = i / cols;
        
        clients[i].x = x + gap + (col * (cell_width + gap));
        clients[i].y = y + gap + (row * (cell_height + gap));
        clients[i].width = cell_width;
        clients[i].height = cell_height;
    }
}

/* Fibonacci layout - golden ratio spiral */
void layout_fibonacci(LayoutClient *clients, int num_clients, int x, int y, int width, int height, int gap) {
    if (num_clients == 0) return;
    if (num_clients == 1) {
        if (!clients[0].is_floating) {
            clients[0].x = x + gap;
            clients[0].y = y + gap;
            clients[0].width = width - (gap * 2);
            clients[0].height = height - (gap * 2);
        }
        return;
    }
    
    // Golden ratio
    double phi = 1.618033988749;
    int main_width = (int)(width / phi);
    int main_height = (int)(height / phi);
    
    // Main window (largest)
    if (!clients[0].is_floating) {
        clients[0].x = x + gap;
        clients[0].y = y + gap;
        clients[0].width = main_width - gap;
        clients[0].height = height - (gap * 2);
    }
    
    // Remaining windows in spiral
    int remaining_x = x + main_width;
    int remaining_y = y;
    int remaining_width = width - main_width;
    int remaining_height = height;
    
    if (num_clients > 1) {
        layout_fibonacci(&clients[1], num_clients - 1, remaining_x, remaining_y, 
                       remaining_width, remaining_height, gap);
    }
}

/* Dwindle layout - binary tree split */
void layout_dwindle(LayoutClient *clients, int num_clients, int x, int y, int width, int height, int gap) {
    if (num_clients == 0) return;
    if (num_clients == 1) {
        if (!clients[0].is_floating) {
            clients[0].x = x + gap;
            clients[0].y = y + gap;
            clients[0].width = width - (gap * 2);
            clients[0].height = height - (gap * 2);
        }
        return;
    }
    
    // Split direction alternates
    static int split_horizontal = 1;
    split_horizontal = !split_horizontal;
    
    int mid = num_clients / 2;
    
    if (split_horizontal) {
        // Horizontal split
        int top_height = height / 2;
        int bottom_height = height - top_height;
        
        layout_dwindle(clients, mid, x, y, width, top_height, gap);
        layout_dwindle(&clients[mid], num_clients - mid, x, y + top_height, width, bottom_height, gap);
    } else {
        // Vertical split
        int left_width = width / 2;
        int right_width = width - left_width;
        
        layout_dwindle(clients, mid, x, y, left_width, height, gap);
        layout_dwindle(&clients[mid], num_clients - mid, x + left_width, y, right_width, height, gap);
    }
}

