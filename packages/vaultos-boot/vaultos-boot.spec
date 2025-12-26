# VaultOS Boot Themes RPM Spec File
# GRUB and Plymouth boot themes

%define name vaultos-boot
%define version 1.0.0
%define release 1

Summary: Fallout-themed boot themes for GRUB and Plymouth
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: System Environment/Base
Source0: %{name}-%{version}.tar.gz
Requires: grub2, plymouth

%description
Fallout-themed boot themes for GRUB bootloader and Plymouth
boot splash with Pip-Boy green aesthetic and Vault-Tec branding.

%prep
%setup -q

%build
# No build step needed

%install
# Install GRUB theme
install -d %{buildroot}%{_datadir}/grub/themes/vaultos
install -m 644 grub/theme.txt %{buildroot}%{_datadir}/grub/themes/vaultos/
install -m 644 grub/*.png %{buildroot}%{_datadir}/grub/themes/vaultos/ 2>/dev/null || true

# Install Plymouth theme
install -d %{buildroot}%{_datadir}/plymouth/themes/vaultos
install -m 644 plymouth/vaultos.plymouth %{buildroot}%{_datadir}/plymouth/themes/vaultos/
install -m 644 plymouth/vaultos.script %{buildroot}%{_datadir}/plymouth/themes/vaultos/
install -m 644 plymouth/*.png %{buildroot}%{_datadir}/plymouth/themes/vaultos/ 2>/dev/null || true

%post
# Configure GRUB theme
if [ -f /etc/default/grub ]; then
    if ! grep -q "GRUB_THEME=" /etc/default/grub; then
        echo "GRUB_THEME=%{_datadir}/grub/themes/vaultos/theme.txt" >> /etc/default/grub
    fi
    if command -v grub2-mkconfig &> /dev/null; then
        grub2-mkconfig -o /boot/grub2/grub.cfg
    fi
fi

# Configure Plymouth theme
if command -v plymouth-set-default-theme &> /dev/null; then
    plymouth-set-default-theme vaultos
fi

%files
%{_datadir}/grub/themes/vaultos/
%{_datadir}/plymouth/themes/vaultos/

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of boot themes

