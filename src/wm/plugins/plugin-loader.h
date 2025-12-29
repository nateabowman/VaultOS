/*
 * VaultWM Plugin Loader API
 */

#ifndef VAULTWM_PLUGIN_LOADER_H
#define VAULTWM_PLUGIN_LOADER_H

#include <stdint.h>

#define PLUGIN_NAME_MAX 64
#define PLUGIN_VERSION_MAX 16

/* Plugin types */
typedef enum {
    PLUGIN_TYPE_STATUSBAR = 1,
    PLUGIN_TYPE_WM = 2,
    PLUGIN_TYPE_THEME = 3,
    PLUGIN_TYPE_APP = 4
} PluginType;

/* Plugin structure */
typedef struct {
    char name[PLUGIN_NAME_MAX];
    char version[PLUGIN_VERSION_MAX];
    PluginType type;
    void *handle;
    void *data;  // Plugin-specific data
} Plugin;

/* Plugin function types */
typedef int (*PluginInitFunc)(Plugin *plugin);
typedef void (*PluginCleanupFunc)(Plugin *plugin);
typedef const char* (*PluginOutputFunc)(Plugin *plugin);
typedef void (*PluginUpdateFunc)(Plugin *plugin);

/* Load plugin from path */
int plugin_load(const char *plugin_path, const char *plugin_name);

/* Unload plugin */
void plugin_unload(const char *plugin_name);

/* Load all plugins from directory */
int plugin_load_directory(const char *dir_path);

/* Load all plugins (system and user) */
int plugin_load_all(void);

/* Get plugin by name */
Plugin* plugin_get(const char *plugin_name);

/* Get all plugins */
Plugin* plugin_get_all(int *count);

/* Cleanup all plugins */
void plugin_cleanup_all(void);

#endif /* VAULTWM_PLUGIN_LOADER_H */

