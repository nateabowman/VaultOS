# VaultWM Wayland Support

## Status

Wayland support is currently in the research and design phase. The architecture has been designed, but full implementation is pending.

## Architecture

VaultWM uses a backend abstraction layer to support both X11 and Wayland:

- **Backend Abstraction**: Common interface for window management operations
- **X11 Backend**: Existing implementation (fully functional)
- **Wayland Backend**: Planned implementation using wlroots (not yet implemented)

## Implementation Requirements

### Dependencies

To implement the Wayland backend, the following are required:

- `wlroots` (>= 0.16) - Wayland compositor library
- `wayland-protocols` - Wayland protocol definitions
- `libwayland-dev` - Wayland development libraries

### Build Configuration

When Wayland support is implemented, the Makefile will need:

```makefile
WAYLAND_CFLAGS = $(shell pkg-config --cflags wlroots wayland-server)
WAYLAND_LIBS = $(shell pkg-config --libs wlroots wayland-server)
```

## Migration Path

1. **Phase 1**: Backend abstraction (current)
2. **Phase 2**: Wayland backend implementation
3. **Phase 3**: Feature parity with X11
4. **Phase 4**: Wayland-specific enhancements

## Current Limitations

- Wayland backend is not yet implemented
- VaultWM currently only supports X11
- Backend abstraction layer is designed but not fully integrated

## Future Work

- [ ] Implement wlroots integration
- [ ] Port window management to Wayland
- [ ] Implement Wayland-specific features
- [ ] Add protocol detection and switching
- [ ] Create migration documentation

## References

- [wlroots Documentation](https://gitlab.freedesktop.org/wlroots/wlroots)
- [Wayland Protocol](https://wayland.freedesktop.org/)
- [Sway WM](https://github.com/swaywm/sway) - Reference implementation using wlroots

