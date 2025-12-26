# VaultOS Windows Build Wrapper
# This script helps set up and run VaultOS builds on Windows

Write-Host "=== VaultOS Build Script for Windows ===" -ForegroundColor Green
Write-Host ""

# Check for WSL
$wslAvailable = Get-Command wsl -ErrorAction SilentlyContinue
if (-not $wslAvailable) {
    Write-Host "ERROR: WSL (Windows Subsystem for Linux) is not installed." -ForegroundColor Red
    Write-Host "Please install WSL from: https://docs.microsoft.com/en-us/windows/wsl/install" -ForegroundColor Yellow
    exit 1
}

Write-Host "WSL is available. Checking for Fedora..." -ForegroundColor Green

# Check for Fedora in WSL
$fedoraDistros = wsl -l -q | Select-String -Pattern "fedora|Fedora" -CaseSensitive:$false
if (-not $fedoraDistros) {
    Write-Host ""
    Write-Host "Fedora is not installed in WSL." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To build VaultOS, you need Fedora Linux. Options:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Option 1: Install Fedora in WSL" -ForegroundColor Cyan
    Write-Host "  1. Download Fedora from: https://github.com/fedora-cloud/docker-brew-fedora" -ForegroundColor White
    Write-Host "  2. Or use: wsl --install -d Fedora" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 2: Use a Fedora VM" -ForegroundColor Cyan
    Write-Host "  - Download Fedora Workstation ISO" -ForegroundColor White
    Write-Host "  - Install in VirtualBox/VMware/Hyper-V" -ForegroundColor White
    Write-Host ""
    Write-Host "Option 3: Use Docker (if available)" -ForegroundColor Cyan
    Write-Host "  - Run: docker run -it fedora:latest" -ForegroundColor White
    Write-Host ""
    Write-Host "The build scripts require Fedora-specific tools:" -ForegroundColor Yellow
    Write-Host "  - rpmbuild, mock, lorax, livemedia-creator, dnf" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "Fedora found in WSL!" -ForegroundColor Green
Write-Host ""

# Get the project path in WSL format
$projectPath = (Get-Location).Path
$wslPath = $projectPath -replace 'C:\\', '/mnt/c/' -replace '\\', '/'

Write-Host "Project path (Windows): $projectPath" -ForegroundColor Cyan
Write-Host "Project path (WSL): $wslPath" -ForegroundColor Cyan
Write-Host ""

Write-Host "To build VaultOS, run these commands in Fedora WSL:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  wsl -d Fedora" -ForegroundColor White
Write-Host "  cd $wslPath" -ForegroundColor White
Write-Host "  ./scripts/setup-build-env.sh" -ForegroundColor White
Write-Host "  ./scripts/build-packages.sh" -ForegroundColor White
Write-Host "  ./scripts/build-iso.sh" -ForegroundColor White
Write-Host ""

Write-Host "Or run this script to attempt automatic setup:" -ForegroundColor Yellow
$continue = Read-Host "Continue with automatic setup? (y/n)"
if ($continue -eq 'y' -or $continue -eq 'Y') {
    Write-Host ""
    Write-Host "Setting up Fedora environment..." -ForegroundColor Green
    
    # Try to run setup in Fedora WSL
    wsl -d Fedora bash -c "cd $wslPath && ./scripts/setup-build-env.sh"
    
    Write-Host ""
    Write-Host "Setup complete! Now building packages..." -ForegroundColor Green
    wsl -d Fedora bash -c "cd $wslPath && ./scripts/build-packages.sh"
    
    Write-Host ""
    Write-Host "Building ISO..." -ForegroundColor Green
    wsl -d Fedora bash -c "cd $wslPath && ./scripts/build-iso.sh"
    
    Write-Host ""
    Write-Host "Build complete! Check the iso/ directory." -ForegroundColor Green
} else {
    Write-Host "Build cancelled. Run the commands manually in Fedora WSL." -ForegroundColor Yellow
}

