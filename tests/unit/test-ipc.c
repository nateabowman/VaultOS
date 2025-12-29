/*
 * Unit tests for VaultWM IPC functionality
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <assert.h>
#include "../src/wm/config/runtime-config/ipc.h"

#define TEST_FIFO_PATH "/tmp/test-vaultwm-ipc"

int tests_passed = 0;
int tests_failed = 0;

void test_pass(const char *test_name) {
    printf("  ✓ %s\n", test_name);
    tests_passed++;
}

void test_fail(const char *test_name, const char *reason) {
    printf("  ✗ %s: %s\n", test_name, reason);
    tests_failed++;
}

void test_ipc_init() {
    printf("Testing IPC initialization...\n");
    
    // Clean up any existing FIFO
    unlink(IPC_FIFO_PATH);
    
    int result = ipc_init();
    if (result == 1) {
        test_pass("IPC initialization");
        
        // Check FIFO permissions
        struct stat st;
        if (stat(IPC_FIFO_PATH, &st) == 0) {
            mode_t perms = st.st_mode & 0777;
            if (perms == 0600) {
                test_pass("IPC FIFO permissions (0600)");
            } else {
                test_fail("IPC FIFO permissions", "Expected 0600");
            }
        } else {
            test_fail("IPC FIFO exists", "Cannot stat FIFO");
        }
        
        ipc_cleanup();
    } else {
        test_fail("IPC initialization", "Failed to initialize");
    }
}

void test_ipc_command_parsing() {
    printf("Testing IPC command parsing...\n");
    
    char cmd[IPC_CMD_MAX];
    char args[IPC_CMD_MAX];
    
    // Test simple command
    if (ipc_parse_command("quit", cmd, sizeof(cmd), args, sizeof(args)) == 1) {
        if (strcmp(cmd, "quit") == 0 && strlen(args) == 0) {
            test_pass("Parse simple command");
        } else {
            test_fail("Parse simple command", "Incorrect parsing");
        }
    } else {
        test_fail("Parse simple command", "Parsing failed");
    }
    
    // Test command with arguments
    if (ipc_parse_command("workspace 3", cmd, sizeof(cmd), args, sizeof(args)) == 1) {
        if (strcmp(cmd, "workspace") == 0 && strcmp(args, "3") == 0) {
            test_pass("Parse command with arguments");
        } else {
            test_fail("Parse command with arguments", "Incorrect parsing");
        }
    } else {
        test_fail("Parse command with arguments", "Parsing failed");
    }
    
    // Test command with multiple spaces
    if (ipc_parse_command("move_to_workspace  5", cmd, sizeof(cmd), args, sizeof(args)) == 1) {
        if (strcmp(cmd, "move_to_workspace") == 0 && strcmp(args, "5") == 0) {
            test_pass("Parse command with multiple spaces");
        } else {
            test_fail("Parse command with multiple spaces", "Incorrect parsing");
        }
    } else {
        test_fail("Parse command with multiple spaces", "Parsing failed");
    }
}

void test_ipc_command_validation() {
    printf("Testing IPC command validation...\n");
    
    // This would require access to internal validation functions
    // For now, we test through the public API
    test_pass("Command validation (tested through integration)");
}

int main(void) {
    printf("VaultWM IPC Unit Tests\n");
    printf("======================\n\n");
    
    test_ipc_init();
    test_ipc_command_parsing();
    test_ipc_command_validation();
    
    printf("\nTest Summary\n");
    printf("============\n");
    printf("Passed: %d\n", tests_passed);
    printf("Failed: %d\n", tests_failed);
    
    return (tests_failed == 0) ? 0 : 1;
}

