/*
 * VaultWM Window Tagging System
 * Tag windows for organization and filtering
 */

#ifndef VAULTWM_WINDOW_TAGS_H
#define VAULTWM_WINDOW_TAGS_H

#include <X11/Xlib.h>

#define MAX_TAGS 16
#define TAG_NAME_MAX 32
#define MAX_TAGS_PER_WINDOW 8

typedef struct {
    char name[TAG_NAME_MAX];
    unsigned int mask;  // Bitmask for tag
} Tag;

typedef struct {
    Tag tags[MAX_TAGS];
    int num_tags;
    unsigned int next_mask;
} TagManager;

/* Initialize tag manager */
int tag_manager_init(TagManager *tm);

/* Create a new tag */
int tag_create(TagManager *tm, const char *name);

/* Find tag by name */
Tag* tag_find(TagManager *tm, const char *name);

/* Get tag by index */
Tag* tag_get(TagManager *tm, int index);

/* Add tag to window */
void window_add_tag(Window win, unsigned int tag_mask);

/* Remove tag from window */
void window_remove_tag(Window win, unsigned int tag_mask);

/* Get window tags */
unsigned int window_get_tags(Window win);

/* Filter windows by tag */
int window_has_tag(Window win, unsigned int tag_mask);

/* Cleanup tag manager */
void tag_manager_cleanup(TagManager *tm);

#endif /* VAULTWM_WINDOW_TAGS_H */

