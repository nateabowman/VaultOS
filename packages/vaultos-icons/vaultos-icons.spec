# VaultOS Icons RPM Spec File
# Fallout-themed icon theme

%define name vaultos-icons
%define version 1.0.0
%define release 1

Summary: Fallout-themed icon theme for VaultOS
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: User Interface/Desktops
Source0: %{name}-%{version}.tar.gz
Requires: gtk-update-icon-cache

%description
VaultOS icon theme with Fallout aesthetic featuring Pip-Boy green
and Vault-Tec color schemes. Includes icons for applications,
file types, devices, and system status indicators in multiple sizes.

%prep
%setup -q

%build
# No build step needed for icons

%install
# Install icon theme
install -d %{buildroot}%{_datadir}/icons/VaultOS
cp -r VaultOS/* %{buildroot}%{_datadir}/icons/VaultOS/

%post
# Update icon cache
if [ -d %{_datadir}/icons/VaultOS ]; then
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t %{_datadir}/icons/VaultOS || true
    fi
fi

%postun
# Update icon cache after removal
if command -v gtk-update-icon-cache &> /dev/null; then
    if [ -d %{_datadir}/icons/VaultOS ]; then
        gtk-update-icon-cache -f -t %{_datadir}/icons/VaultOS || true
    fi
fi

%files
%{_datadir}/icons/VaultOS/

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of VaultOS icon theme

