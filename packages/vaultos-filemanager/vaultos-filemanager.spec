# VaultOS File Manager Configuration RPM Spec File
# Themed file manager configurations

%define name vaultos-filemanager
%define version 1.0.0
%define release 1

Summary: Fallout-themed file manager configurations for VaultOS
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: User Interface/Desktops
Source0: %{name}-%{version}.tar.gz

%description
File manager configurations with Fallout aesthetic for Ranger,
Thunar, and Nautilus. Includes Pip-Boy green color schemes and
Fallout-themed customizations.

%prep
%setup -q

%build
# No build step needed

%install
# Install Ranger configuration
install -d %{buildroot}%{_sysconfdir}/skel/.config/ranger
install -m 644 ranger/rc.conf %{buildroot}%{_sysconfdir}/skel/.config/ranger/

# Install Thunar configuration
install -d %{buildroot}%{_datadir}/vaultos/filemanager
install -m 644 thunar.conf %{buildroot}%{_datadir}/vaultos/filemanager/

# Install Nautilus CSS
install -m 644 nautilus.css %{buildroot}%{_datadir}/vaultos/filemanager/

%files
%config(noreplace) %{_sysconfdir}/skel/.config/ranger/rc.conf
%{_datadir}/vaultos/filemanager/

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of file manager configurations

