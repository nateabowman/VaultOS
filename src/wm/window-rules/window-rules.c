/*
 * VaultWM Window Rules Implementation
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "window-rules.h"

int window_rules_init(WindowRules *wr) {
    if (!wr) {
        return 0;
    }
    
    wr->num_rules = 0;
    memset(wr->rules, 0, sizeof(wr->rules));
    return 1;
}

static RuleType parse_rule_type(const char *type_str) {
    if (strcmp(type_str, "float") == 0 || strcmp(type_str, "floating") == 0) {
        return RULE_TYPE_FLOAT;
    } else if (strcmp(type_str, "workspace") == 0) {
        return RULE_TYPE_WORKSPACE;
    } else if (strcmp(type_str, "layout") == 0) {
        return RULE_TYPE_LAYOUT;
    } else if (strcmp(type_str, "size") == 0) {
        return RULE_TYPE_SIZE;
    } else if (strcmp(type_str, "position") == 0) {
        return RULE_TYPE_POSITION;
    }
    return 0;
}

int window_rules_load(const char *config_path, WindowRules *wr) {
    FILE *file;
    char line[256];
    char class_name[RULE_NAME_MAX];
    char instance_name[RULE_NAME_MAX];
    char rule_type_str[32];
    char value[RULE_VALUE_MAX];
    
    if (!wr || !config_path) {
        return 0;
    }
    
    window_rules_init(wr);
    
    file = fopen(config_path, "r");
    if (!file) {
        return 0;  // File doesn't exist, use defaults
    }
    
    while (fgets(line, sizeof(line), file) && wr->num_rules < MAX_RULES) {
        // Skip comments and empty lines
        if (line[0] == '#' || line[0] == '\n' || line[0] == '\0') {
            continue;
        }
        
        // Parse rule: class:instance:type=value
        // Or: class:type=value (instance is *)
        int parsed = sscanf(line, "%63[^:]:%63[^:]:%31[^=]=%127s", 
                         class_name, instance_name, rule_type_str, value);
        
        if (parsed == 4) {
            // class:instance:type=value
            RuleType type = parse_rule_type(rule_type_str);
            if (type != 0) {
                window_rules_add(wr, class_name, instance_name, type, value);
            }
        } else {
            // Try class:type=value format
            parsed = sscanf(line, "%63[^:]:%31[^=]=%127s", 
                           class_name, rule_type_str, value);
            if (parsed == 3) {
                RuleType type = parse_rule_type(rule_type_str);
                if (type != 0) {
                    window_rules_add(wr, class_name, "*", type, value);
                }
            }
        }
    }
    
    fclose(file);
    return 1;
}

int window_rules_add(WindowRules *wr, const char *class_name, const char *instance_name, 
                     RuleType type, const char *value) {
    if (!wr || wr->num_rules >= MAX_RULES) {
        return 0;
    }
    
    WindowRule *rule = &wr->rules[wr->num_rules];
    
    strncpy(rule->class_name, class_name, sizeof(rule->class_name) - 1);
    rule->class_name[sizeof(rule->class_name) - 1] = '\0';
    
    strncpy(rule->instance_name, instance_name, sizeof(rule->instance_name) - 1);
    rule->instance_name[sizeof(rule->instance_name) - 1] = '\0';
    
    rule->type = type;
    
    strncpy(rule->value, value, sizeof(rule->value) - 1);
    rule->value[sizeof(rule->value) - 1] = '\0';
    
    rule->priority = wr->num_rules;  // Later rules have higher priority
    
    wr->num_rules++;
    return 1;
}

void window_rules_apply(WindowRules *wr, Window win, const char *class_name, const char *instance_name) {
    int i;
    WindowRule *best_rule = NULL;
    int best_priority = -1;
    
    if (!wr || !class_name) {
        return;
    }
    
    // Find best matching rule (highest priority)
    for (i = 0; i < wr->num_rules; i++) {
        WindowRule *rule = &wr->rules[i];
        
        // Check class name match
        if (strcmp(rule->class_name, "*") != 0 && 
            strcmp(rule->class_name, class_name) != 0) {
            continue;
        }
        
        // Check instance name match
        if (strcmp(rule->instance_name, "*") != 0 && 
            instance_name && strcmp(rule->instance_name, instance_name) != 0) {
            continue;
        }
        
        // This rule matches, check if it has higher priority
        if (rule->priority > best_priority) {
            best_rule = rule;
            best_priority = rule->priority;
        }
    }
    
    // Apply best matching rule
    if (best_rule) {
        // Rule application would be handled by window manager
        // This function identifies the rule to apply
    }
}

void window_rules_cleanup(WindowRules *wr) {
    if (wr) {
        wr->num_rules = 0;
    }
}

