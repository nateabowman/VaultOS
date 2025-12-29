# VaultWM Wayland Support

## Overview

This document outlines the design and implementation plan for adding Wayland support to VaultWM while maintaining X11 compatibility.

## Architecture

### Dual-Protocol Support

VaultWM will support both X11 and Wayland protocols simultaneously:

1. **Protocol Detection**: Automatically detect available protocol at runtime
2. **Backend Abstraction**: Abstract window management operations behind a common interface
3. **Protocol-Specific Implementations**: Separate implementations for X11 and Wayland

### Compositor Library Evaluation

#### Option 1: wlroots (Recommended)
- **Pros**: 
  - Modern, actively maintained
  - Used by Sway, dwl, and other popular WMs
  - Comprehensive feature set
  - Good documentation
- **Cons**:
  - Larger dependency
  - Steeper learning curve
- **Decision**: Primary choice for Wayland backend

#### Option 2: libweston
- **Pros**:
  - Part of Weston reference compositor
  - Well-tested
- **Cons**:
  - Less actively developed
  - More limited feature set
- **Decision**: Fallback option if wlroots proves unsuitable

## Implementation Plan

### Phase 1: Research and Design
- [x] Evaluate compositor libraries
- [x] Design architecture for dual-protocol support
- [ ] Create protocol abstraction layer
- [ ] Design migration path

### Phase 2: Backend Abstraction
- [ ] Create `wm_backend.h` interface
- [ ] Implement X11 backend (refactor existing code)
- [ ] Implement Wayland backend (wlroots)
- [ ] Protocol detection and initialization

### Phase 3: Feature Parity
- [ ] Window management (create, destroy, resize, move)
- [ ] Workspace support
- [ ] Layout algorithms
- [ ] Status bar
- [ ] IPC support

### Phase 4: Wayland-Specific Features
- [ ] Client isolation (security)
- [ ] Improved multi-monitor support
- [ ] Touch and gesture support
- [ ] Performance optimizations

## Protocol Abstraction Layer

```c
typedef struct {
    int (*init)(void);
    void (*cleanup)(void);
    int (*create_window)(Window *win, int x, int y, int w, int h);
    void (*destroy_window)(Window win);
    void (*resize_window)(Window win, int w, int h);
    void (*move_window)(Window win, int x, int y);
    void (*focus_window)(Window win);
    // ... more operations
} WMBackend;
```

## Migration Guide

### For Users

1. **Automatic Detection**: VaultWM will automatically use Wayland if available
2. **Fallback**: Falls back to X11 if Wayland is not available
3. **Configuration**: No changes required to existing configs

### For Developers

1. **Backend Selection**: Use `wm_backend_init()` to initialize appropriate backend
2. **Protocol-Specific Code**: Isolate protocol-specific code in backend implementations
3. **Testing**: Test both X11 and Wayland backends

## Dependencies

### Wayland Backend (wlroots)
- `wlroots` (>= 0.16)
- `wayland-protocols`
- `libwayland-dev`

### X11 Backend (existing)
- `libX11-dev`
- `libXrandr-dev`

## Timeline

- **Research & Design**: 1-2 weeks
- **Backend Abstraction**: 2-3 weeks
- **Wayland Implementation**: 3-4 weeks
- **Testing & Polish**: 1-2 weeks

**Total**: 7-11 weeks

## Status

Currently in research phase. Wayland support is planned but not yet implemented.

