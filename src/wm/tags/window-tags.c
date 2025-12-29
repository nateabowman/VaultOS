/*
 * VaultWM Window Tagging Implementation
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include "window-tags.h"

#define TAG_ATOM_NAME "_VAULTWM_TAGS"

static Atom tag_atom = None;

int tag_manager_init(TagManager *tm) {
    if (!tm) {
        return 0;
    }
    
    tm->num_tags = 0;
    tm->next_mask = 1;  // Start with bit 1 (bit 0 reserved)
    memset(tm->tags, 0, sizeof(tm->tags));
    
    return 1;
}

int tag_create(TagManager *tm, const char *name) {
    if (!tm || !name || tm->num_tags >= MAX_TAGS) {
        return 0;
    }
    
    // Check if tag already exists
    if (tag_find(tm, name) != NULL) {
        return 0;
    }
    
    Tag *tag = &tm->tags[tm->num_tags];
    strncpy(tag->name, name, sizeof(tag->name) - 1);
    tag->name[sizeof(tag->name) - 1] = '\0';
    tag->mask = tm->next_mask;
    
    tm->next_mask <<= 1;  // Next tag gets next bit
    tm->num_tags++;
    
    return 1;
}

Tag* tag_find(TagManager *tm, const char *name) {
    int i;
    
    if (!tm || !name) {
        return NULL;
    }
    
    for (i = 0; i < tm->num_tags; i++) {
        if (strcmp(tm->tags[i].name, name) == 0) {
            return &tm->tags[i];
        }
    }
    
    return NULL;
}

Tag* tag_get(TagManager *tm, int index) {
    if (!tm || index < 0 || index >= tm->num_tags) {
        return NULL;
    }
    
    return &tm->tags[index];
}

void window_add_tag(Window win, unsigned int tag_mask) {
    // This would store tags in window properties
    // Simplified implementation - full version would use X11 properties
}

void window_remove_tag(Window win, unsigned int tag_mask) {
    // Remove tag from window
}

unsigned int window_get_tags(Window win) {
    // Retrieve tags from window properties
    return 0;
}

int window_has_tag(Window win, unsigned int tag_mask) {
    unsigned int tags = window_get_tags(win);
    return (tags & tag_mask) != 0;
}

void tag_manager_cleanup(TagManager *tm) {
    if (tm) {
        tm->num_tags = 0;
        tm->next_mask = 1;
    }
}

