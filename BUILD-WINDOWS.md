# Building VaultOS on Windows

Since VaultOS is a Linux distribution, it cannot be built directly on Windows. You need a Linux environment, specifically **Fedora Linux**, to build it.

## Why Fedora?

The build scripts use Fedora-specific tools:
- `rpmbuild` - RPM package builder
- `mock` - Build environment isolation
- `lorax` - Live CD creation
- `livemedia-creator` - ISO builder
- `dnf` - Package manager

## Options for Building on Windows

### Option 1: WSL2 with Fedora (Recommended)

1. **Install Fedora in WSL2:**
   ```powershell
   # Download Fedora container
   wsl --import Fedora C:\WSL\Fedora https://github.com/fedora-cloud/docker-brew-fedora/raw/39/x86_64/fedora-39-x86_64.tar.xz
   
   # Or use Fedora Remix for WSL
   # Download from: https://github.com/WhitewaterFoundry/Fedora-Remix-for-WSL
   ```

2. **Set up the build environment:**
   ```bash
   # In Fedora WSL
   wsl -d Fedora
   cd /mnt/c/Users/nbowm/OneDrive/Desktop/VaultOS
   ./scripts/setup-build-env.sh
   ```

3. **Build:**
   ```bash
   ./scripts/build-packages.sh
   ./scripts/build-iso.sh
   ```

### Option 2: Virtual Machine

1. **Download Fedora Workstation ISO:**
   - https://getfedora.org/en/workstation/download/

2. **Install in VirtualBox/VMware/Hyper-V:**
   - Allocate at least 4GB RAM
   - Allocate at least 40GB disk space
   - Enable virtualization in BIOS

3. **Copy project to VM and build:**
   ```bash
   # In Fedora VM
   git clone <your-repo> # or copy files
   cd VaultOS
   ./scripts/setup-build-env.sh
   ./scripts/build-packages.sh
   ./scripts/build-iso.sh
   ```

### Option 3: Docker Container

1. **Install Docker Desktop for Windows**

2. **Run Fedora container:**
   ```powershell
   docker run -it -v ${PWD}:/vaultos fedora:latest bash
   ```

3. **Inside container:**
   ```bash
   cd /vaultos
   dnf install -y lorax livemedia-creator rpm-build mock
   ./scripts/setup-build-env.sh
   ./scripts/build-packages.sh
   ./scripts/build-iso.sh
   ```

### Option 4: Cloud/Remote Linux Server

Use a cloud instance (AWS, Azure, DigitalOcean) or remote Linux server:
- SSH into the server
- Clone/copy the project
- Run build scripts

## Quick Start Script for Windows

I've created `scripts/build-windows.ps1` which will:
1. Check for WSL
2. Check for Fedora in WSL
3. Guide you through setup
4. Attempt to run builds in Fedora WSL

Run it with:
```powershell
.\scripts\build-windows.ps1
```

## What You Can Do on Windows

While you can't build the ISO on Windows, you can:

1. **Edit source files** - All configuration files are text-based
2. **Validate scripts** - Check syntax (if you have WSL with any Linux)
3. **Design assets** - Create icons, wallpapers, graphics
4. **Test in VM** - Once built, test the ISO in VirtualBox/VMware

## Validation Script

To validate scripts without building:
```powershell
wsl bash scripts/validate-scripts.sh
```

This checks:
- Bash script syntax
- Project structure
- File presence
- Code compilation (if gcc available)

## Next Steps

1. Choose one of the options above
2. Set up Fedora environment
3. Run the build scripts
4. Get your VaultOS ISO!

## Troubleshooting

### WSL Issues
- Make sure WSL2 is enabled: `wsl --set-default-version 2`
- Update WSL: `wsl --update`

### Build Errors
- Ensure you have enough disk space (10GB+ free)
- Run as root for some operations: `sudo ./scripts/setup-build-env.sh`
- Check logs in `/var/log/` for detailed errors

### Missing Tools
```bash
sudo dnf install -y lorax lorax-templates-generic livemedia-creator \
    rpm-build rpmdevtools mock createrepo gcc gcc-c++ make cmake \
    pkgconfig git fontforge imagemagick
```

## Summary

**You cannot build VaultOS directly on Windows.** You need:
- ✅ Fedora Linux (WSL, VM, Docker, or remote)
- ✅ Build tools installed
- ✅ Sufficient disk space
- ✅ Root/sudo access

The project files are ready - you just need the right environment to build them!

