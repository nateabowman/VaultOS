# VaultOS Live CD Build

Configuration and scripts for building VaultOS Live CD.

## Prerequisites

Install build tools:
```bash
sudo dnf install lorax lorax-templates-generic livemedia-creator createrepo
```

## Building

### Quick Build
```bash
./build-livecd.sh
```

### Manual Build
```bash
livemedia-creator \
    --make-iso \
    --iso-size=4096 \
    --ks=../kickstart/vaultos.ks \
    --iso-name=VaultOS.iso \
    --project="VaultOS" \
    --releasever=40 \
    --volid="VaultOS"
```

## Configuration

Edit `livecd.conf` to customize:
- ISO name and volume ID
- Release version
- Package lists
- Repository configuration

## Output

Built ISO will be in `../../iso/` directory.

## Testing

Test the ISO in a virtual machine:
```bash
qemu-system-x86_64 -cdrom iso/VaultOS-*.iso -m 2048
```

## Installation

The Live CD can be:
1. Burned to DVD
2. Written to USB drive
3. Used in virtual machines
4. Installed to hard drive

