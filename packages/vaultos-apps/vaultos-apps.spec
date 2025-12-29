# VaultOS Applications RPM Spec File
# Collection of application themes and configurations

%define name vaultos-apps
%define version 1.0.0
%define release 1

Summary: Fallout-themed application configurations for VaultOS
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: User Interface/Desktops
Source0: %{name}-%{version}.tar.gz

%description
Collection of application themes and configurations with Fallout
aesthetic including Firefox, VS Code, MPV, and other popular
applications. All themed with Pip-Boy green and Vault-Tec colors.

%prep
%setup -q

%build
# No build step needed

%install
# Install application configurations
install -d %{buildroot}%{_datadir}/vaultos/apps
install -m 644 firefox-userChrome.css %{buildroot}%{_datadir}/vaultos/apps/
install -m 644 vscode-settings.json %{buildroot}%{_datadir}/vaultos/apps/
install -m 644 mpv.conf %{buildroot}%{_datadir}/vaultos/apps/

%files
%{_datadir}/vaultos/apps/

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of application configurations

