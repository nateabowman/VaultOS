# VaultOS Release Process

This document describes the process for creating and publishing VaultOS releases.

## Version Numbering

VaultOS follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Incompatible API or major feature changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

Example: `1.2.3` (Major.Minor.Patch)

## Release Types

### Stable Release
- Production-ready release
- All features tested
- Documentation complete
- Version number: `X.Y.Z`

### Beta Release
- Feature-complete, may have bugs
- For testing purposes
- Version number: `X.Y.Z-beta.N`

### Alpha Release
- Early development release
- Features may be incomplete
- Version number: `X.Y.Z-alpha.N`

### Development Release
- Latest development code
- May be unstable
- Version: `X.Y.Z-dev` or git commit hash

## Release Checklist

### Pre-Release

- [ ] All features for release are complete
- [ ] All tests pass
- [ ] Documentation is up to date
- [ ] CHANGELOG.md is updated
- [ ] Version numbers updated in:
  - Package spec files
  - Source code version strings
  - Documentation
- [ ] Build scripts tested
- [ ] ISO builds successfully
- [ ] Packages build successfully

### Release Steps

1. **Update Version Numbers**
   ```bash
   # Update version in all package spec files
   # Update version in source code
   # Update CHANGELOG.md
   ```

2. **Create Release Branch**
   ```bash
   git checkout -b release/vX.Y.Z
   ```

3. **Final Testing**
   - Build all packages
   - Build ISO
   - Test installation
   - Test all major features

4. **Create Release Tag**
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

5. **Build Release Artifacts**
   ```bash
   ./scripts/build-automation.sh
   ```

6. **Create GitHub Release**
   - Go to GitHub releases page
   - Click "Draft a new release"
   - Select tag `vX.Y.Z`
   - Title: "VaultOS X.Y.Z"
   - Description: Copy from CHANGELOG.md
   - Upload ISO and packages

7. **Update Repository**
   ```bash
   ./scripts/repo/add-package.sh /var/www/html/vaultos-repo *.rpm
   ```

8. **Announcement**
   - Update website (if applicable)
   - Post to community channels
   - Update documentation links

### Post-Release

- [ ] Merge release branch to main
- [ ] Bump version to next development version
- [ ] Update CHANGELOG.md with new [Unreleased] section
- [ ] Create release announcement
- [ ] Monitor for issues

## Package Versioning

Package versions follow RPM conventions:
- Format: `version-release`
- Example: `1.0.0-1.fc38`

Update in package spec files:
```spec
%define version 1.0.0
%define release 1
```

## Release Announcement Template

```markdown
# VaultOS X.Y.Z Released

We're pleased to announce the release of VaultOS X.Y.Z!

## What's New

- Feature 1
- Feature 2
- Bug fix 1

## Download

- ISO: [Download Link]
- Repository: [Repository URL]

## Installation

See the [Installation Guide](docs/installation.md) for instructions.

## Upgrade

Existing users can upgrade:
```bash
sudo dnf update
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete list of changes.

## Thanks

Thanks to all contributors and testers!
```

## Release Schedule

VaultOS follows a flexible release schedule:
- **Major releases**: When significant features are ready
- **Minor releases**: Every 2-3 months
- **Patch releases**: As needed for bug fixes

No fixed release dates - releases happen when ready.

## Emergency Releases

For critical security or stability issues:
1. Create hotfix branch
2. Apply fix
3. Test thoroughly
4. Release as patch version
5. Follow normal release process (abbreviated)

## Responsibilities

- **Release Manager**: Coordinates release process
- **Developers**: Complete features, write tests
- **Testers**: Test releases, report issues
- **Documentation**: Update docs for release

## See Also

- [Semantic Versioning](https://semver.org/)
- [CHANGELOG.md](../CHANGELOG.md)
- [Build Documentation](developer.md#building)

