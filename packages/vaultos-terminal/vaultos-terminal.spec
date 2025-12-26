# VaultOS Terminal Themes RPM Spec File
# Terminal color schemes and profiles

%define name vaultos-terminal
%define version 1.0.0
%define release 1

Summary: Fallout-themed terminal color schemes for VaultOS
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: User Interface/Desktops
Source0: %{name}-%{version}.tar.gz

%description
Terminal color schemes and profiles with Pip-Boy green and
Vault-Tec color schemes for various terminal emulators.

%prep
%setup -q

%build
# No build step needed

%install
# Install terminal themes
install -d %{buildroot}%{_datadir}/vaultos/terminal/themes
install -m 644 themes/*.conf %{buildroot}%{_datadir}/vaultos/terminal/themes/

# Install terminal profiles
install -d %{buildroot}%{_datadir}/vaultos/terminal/profiles
install -m 644 profiles/*.yml %{buildroot}%{_datadir}/vaultos/terminal/profiles/
install -m 755 profiles/*.sh %{buildroot}%{_datadir}/vaultos/terminal/profiles/

%files
%{_datadir}/vaultos/terminal/

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of terminal themes

