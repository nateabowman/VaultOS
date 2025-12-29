# VaultOS Performance Tools

Performance optimization and benchmarking tools.

## Tools

### benchmark.sh
System performance benchmark utility.

Usage:
```bash
vaultos-benchmark
```

Tests:
- CPU performance
- Memory bandwidth
- Disk I/O performance
- Window manager status

### system-optimize.sh
Apply system optimizations for better performance.

Usage:
```bash
sudo vaultos-system-optimize
```

Optimizations:
- CPU governor (performance mode)
- I/O scheduler (deadline)
- Memory swappiness
- File system recommendations

**Warning**: Requires root privileges. Some changes may affect system stability or battery life.

## Performance Tips

1. **CPU Governor**: 
   - `performance` - Maximum performance (higher power consumption)
   - `powersave` - Lower power consumption (reduced performance)
   - `ondemand` - Balanced (default)

2. **I/O Scheduler**:
   - `deadline` - Good for SSDs and HDDs
   - `none` - No-op scheduler (for some SSDs)
   - `bfq` - Better for desktop use

3. **Swappiness**:
   - Lower values (10-20) reduce swap usage
   - Good for systems with sufficient RAM
   - Default is usually 60

## See Also

- [System Monitoring](../pipboy-viewer.sh)
- [Hardware Configuration](../hardware/README.md)

