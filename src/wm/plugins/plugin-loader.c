/*
 * VaultWM Plugin Loader
 * Loads and manages plugins for the window manager
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pwd.h>
#include "plugin-loader.h"

#define MAX_PLUGINS 64
#define PLUGIN_DIR_SYSTEM "/usr/share/vaultos/plugins"
#define PLUGIN_DIR_USER_FORMAT "%s/.local/share/vaultos/plugins"

static Plugin plugins[MAX_PLUGINS];
static int num_plugins = 0;

/* Load plugin from shared library */
int plugin_load(const char *plugin_path, const char *plugin_name) {
    void *handle;
    PluginInitFunc init_func;
    Plugin *plugin;
    
    if (num_plugins >= MAX_PLUGINS) {
        fprintf(stderr, "VaultWM: Maximum plugin limit reached\n");
        return 0;
    }
    
    // Open shared library
    handle = dlopen(plugin_path, RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "VaultWM: Failed to load plugin %s: %s\n", plugin_path, dlerror());
        return 0;
    }
    
    // Get init function
    init_func = (PluginInitFunc)dlsym(handle, "plugin_init");
    if (!init_func) {
        fprintf(stderr, "VaultWM: Plugin %s missing init function\n", plugin_name);
        dlclose(handle);
        return 0;
    }
    
    // Initialize plugin
    plugin = &plugins[num_plugins];
    memset(plugin, 0, sizeof(Plugin));
    
    strncpy(plugin->name, plugin_name, sizeof(plugin->name) - 1);
    plugin->name[sizeof(plugin->name) - 1] = '\0';
    plugin->handle = handle;
    
    if (init_func(plugin) != 0) {
        fprintf(stderr, "VaultWM: Plugin %s initialization failed\n", plugin_name);
        dlclose(handle);
        return 0;
    }
    
    num_plugins++;
    return 1;
}

/* Unload plugin */
void plugin_unload(const char *plugin_name) {
    int i;
    
    for (i = 0; i < num_plugins; i++) {
        if (strcmp(plugins[i].name, plugin_name) == 0) {
            PluginCleanupFunc cleanup = (PluginCleanupFunc)dlsym(plugins[i].handle, "plugin_cleanup");
            if (cleanup) {
                cleanup(&plugins[i]);
            }
            
            dlclose(plugins[i].handle);
            
            // Remove from array
            memmove(&plugins[i], &plugins[i + 1], (num_plugins - i - 1) * sizeof(Plugin));
            num_plugins--;
            return;
        }
    }
}

/* Load all plugins from directory */
int plugin_load_directory(const char *dir_path) {
    DIR *dir;
    struct dirent *entry;
    char plugin_path[512];
    struct stat st;
    int loaded = 0;
    
    dir = opendir(dir_path);
    if (!dir) {
        return 0;
    }
    
    while ((entry = readdir(dir)) != NULL) {
        // Skip . and ..
        if (entry->d_name[0] == '.') {
            continue;
        }
        
        snprintf(plugin_path, sizeof(plugin_path), "%s/%s", dir_path, entry->d_name);
        
        // Check if it's a file
        if (stat(plugin_path, &st) != 0) {
            continue;
        }
        
        // Check if it's a shared library
        if (S_ISREG(st.st_mode) && strstr(entry->d_name, ".so") != NULL) {
            // Extract plugin name (remove .so extension)
            char plugin_name[256];
            strncpy(plugin_name, entry->d_name, sizeof(plugin_name) - 1);
            plugin_name[sizeof(plugin_name) - 1] = '\0';
            char *dot = strrchr(plugin_name, '.');
            if (dot) {
                *dot = '\0';
            }
            
            if (plugin_load(plugin_path, plugin_name)) {
                loaded++;
            }
        }
    }
    
    closedir(dir);
    return loaded;
}

/* Load all plugins (system and user) */
int plugin_load_all(void) {
    int loaded = 0;
    char user_plugin_dir[512];
    struct passwd *pw;
    
    // Load system plugins
    if (plugin_load_directory(PLUGIN_DIR_SYSTEM) > 0) {
        loaded++;
    }
    
    // Load user plugins
    pw = getpwuid(getuid());
    if (pw) {
        snprintf(user_plugin_dir, sizeof(user_plugin_dir), PLUGIN_DIR_USER_FORMAT, pw->pw_dir);
        if (plugin_load_directory(user_plugin_dir) > 0) {
            loaded++;
        }
    }
    
    return loaded;
}

/* Get plugin by name */
Plugin* plugin_get(const char *plugin_name) {
    int i;
    
    for (i = 0; i < num_plugins; i++) {
        if (strcmp(plugins[i].name, plugin_name) == 0) {
            return &plugins[i];
        }
    }
    
    return NULL;
}

/* Get all plugins */
Plugin* plugin_get_all(int *count) {
    if (count) {
        *count = num_plugins;
    }
    return plugins;
}

/* Cleanup all plugins */
void plugin_cleanup_all(void) {
    int i;
    
    for (i = 0; i < num_plugins; i++) {
        PluginCleanupFunc cleanup = (PluginCleanupFunc)dlsym(plugins[i].handle, "plugin_cleanup");
        if (cleanup) {
            cleanup(&plugins[i]);
        }
        dlclose(plugins[i].handle);
    }
    
    num_plugins = 0;
}

