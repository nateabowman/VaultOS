# Building VaultOS ISO on Ubuntu

VaultOS is a Fedora-based distribution, so building the ISO on Ubuntu requires using Docker to run Fedora build tools.

## Quick Start

### 1. Install Docker

Run the setup script:
```bash
./scripts/setup-ubuntu-build.sh
```

Or manually:
```bash
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**Important:** After adding yourself to the docker group, log out and log back in (or restart) for the change to take effect.

### 2. Build the ISO

Once Docker is set up:
```bash
./scripts/build-iso-ubuntu.sh
```

This will:
- Pull a Fedora Docker image
- Install Fedora build tools inside the container
- Build the ISO using `livemedia-creator`
- Save the ISO to `iso/` directory

## Build Time

The build process typically takes **15-30 minutes** depending on:
- Your internet connection (first time downloading Fedora packages)
- Your CPU speed
- Available disk space

## Requirements

- **Disk Space:** At least 10GB free space
- **RAM:** At least 4GB recommended
- **Docker:** Installed and running
- **Internet:** Required for downloading packages

## Troubleshooting

### Docker Permission Denied

If you get permission denied errors:
```bash
# Check if you're in the docker group
groups | grep docker

# If not, add yourself and log out/in
sudo usermod -aG docker $USER
```

### Docker Daemon Not Running

```bash
sudo systemctl start docker
sudo systemctl status docker
```

### Build Fails

Check the build log:
```bash
cat build/iso-build.log
```

### Out of Disk Space

Clean up Docker:
```bash
docker system prune -a
```

## Output

The built ISO will be in the `iso/` directory:
```
iso/VaultOS-YYYYMMDD.iso
```

## Testing the ISO

### In QEMU (Virtual Machine)
```bash
sudo apt-get install qemu-system-x86
qemu-system-x86_64 -cdrom iso/VaultOS-*.iso -m 2048
```

### Write to USB Drive
```bash
# Find your USB device
lsblk

# Write ISO (replace sdX with your device)
sudo dd if=iso/VaultOS-*.iso of=/dev/sdX bs=4M status=progress
```

## Manual Build (Advanced)

If you prefer to build manually inside a Docker container:

```bash
docker run --rm -it \
    --privileged \
    -v $(pwd):/vaultos \
    -w /vaultos \
    fedora:latest \
    bash

# Inside container:
dnf install -y lorax livemedia-creator
livemedia-creator --make-iso --ks=build/kickstart/vaultos.ks ...
```

