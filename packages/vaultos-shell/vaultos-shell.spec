# VaultOS Shell Configuration RPM Spec File
# Shell customizations with Pip-Boy prompt

%define name vaultos-shell
%define version 1.0.0
%define release 1

Summary: Fallout-themed shell configurations for VaultOS
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: System Environment/Shells
Source0: %{name}-%{version}.tar.gz

%description
Shell configurations for bash and zsh with Pip-Boy-style prompts
and Fallout-themed aliases and customizations.

%prep
%setup -q

%build
# No build step needed

%install
# Install shell configurations
install -d %{buildroot}%{_sysconfdir}/profile.d
install -m 644 bashrc/vaultos.bashrc %{buildroot}%{_sysconfdir}/profile.d/vaultos.sh

install -d %{buildroot}%{_datadir}/vaultos/shell
install -m 644 bashrc/vaultos.bashrc %{buildroot}%{_datadir}/vaultos/shell/
install -m 644 zshrc/vaultos.zshrc %{buildroot}%{_datadir}/vaultos/shell/

%post
# Source the configuration for new shells
if [ -f /etc/profile.d/vaultos.sh ]; then
    . /etc/profile.d/vaultos.sh
fi

%files
%{_sysconfdir}/profile.d/vaultos.sh
%{_datadir}/vaultos/shell/

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of shell configurations

