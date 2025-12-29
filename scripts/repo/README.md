# VaultOS Repository Management Scripts

Scripts for managing the VaultOS RPM repository.

## Scripts

### create-repo.sh
Creates a new RPM repository structure.

Usage:
```bash
./create-repo.sh [directory]
```

Default directory: `/var/www/html/vaultos-repo`

Creates:
- Repository directory structure (SRPMS, x86_64, noarch, repodata)
- Initial repository metadata
- Repository configuration file (`.repo`)

### update-repo.sh
Updates repository metadata after package changes.

Usage:
```bash
./update-repo.sh [directory]
```

Updates the `repodata/` directory with current package information.

### add-package.sh
Adds a package to the repository and updates metadata.

Usage:
```bash
./add-package.sh [directory] <package.rpm>
```

Example:
```bash
./add-package.sh /var/www/html/vaultos-repo vaultos-themes-1.0.0-1.fc38.x86_64.rpm
```

Automatically:
- Determines package architecture
- Copies package to appropriate directory
- Updates repository metadata

## Repository Structure

```
vaultos-repo/
├── SRPMS/          # Source RPMs
├── x86_64/         # x86_64 architecture packages
├── noarch/         # Architecture-independent packages
├── repodata/       # Repository metadata (generated)
└── vaultos.repo    # Repository configuration file
```

## Using the Repository

1. Create repository:
   ```bash
   ./create-repo.sh /var/www/html/vaultos-repo
   ```

2. Add packages:
   ```bash
   ./add-package.sh /var/www/html/vaultos-repo *.rpm
   ```

3. Configure on client systems:
   ```bash
   sudo cp vaultos.repo /etc/yum.repos.d/
   sudo dnf makecache
   ```

4. Install packages:
   ```bash
   sudo dnf install vaultos-themes vaultos-terminal
   ```

## Requirements

- `createrepo_c` or `createrepo` (for repository metadata)
- `rpm` (for package information)
- Write access to repository directory

Install requirements on Fedora:
```bash
sudo dnf install createrepo_c rpm
```

## Hosting

For remote access, serve the repository directory via HTTP:
- Apache/Nginx web server
- Local file system (file://)
- Cloud storage (S3, etc.)

Update `baseurl` in `.repo` file accordingly.

