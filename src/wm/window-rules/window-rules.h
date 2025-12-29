/*
 * VaultWM Window Rules System
 * Automatic window behavior based on rules
 */

#ifndef VAULTWM_WINDOW_RULES_H
#define VAULTWM_WINDOW_RULES_H

#define MAX_RULES 64
#define RULE_NAME_MAX 64
#define RULE_VALUE_MAX 128

typedef enum {
    RULE_TYPE_FLOAT = 1,
    RULE_TYPE_WORKSPACE = 2,
    RULE_TYPE_LAYOUT = 3,
    RULE_TYPE_SIZE = 4,
    RULE_TYPE_POSITION = 5
} RuleType;

typedef struct {
    char class_name[RULE_NAME_MAX];
    char instance_name[RULE_NAME_MAX];
    RuleType type;
    char value[RULE_VALUE_MAX];
    int priority;
} WindowRule;

typedef struct {
    WindowRule rules[MAX_RULES];
    int num_rules;
} WindowRules;

/* Initialize window rules */
int window_rules_init(WindowRules *wr);

/* Load rules from file */
int window_rules_load(const char *config_path, WindowRules *wr);

/* Apply rules to window */
void window_rules_apply(WindowRules *wr, Window win, const char *class_name, const char *instance_name);

/* Add rule programmatically */
int window_rules_add(WindowRules *wr, const char *class_name, const char *instance_name, 
                     RuleType type, const char *value);

/* Cleanup rules */
void window_rules_cleanup(WindowRules *wr);

#endif /* VAULTWM_WINDOW_RULES_H */

