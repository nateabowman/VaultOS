# VaultOS Security Package RPM Spec File
# Security hardening scripts and configurations

%define name vaultos-security
%define version 1.0.0
%define release 1

Summary: Security hardening scripts and configurations for VaultOS
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: System Environment/Base
Source0: %{name}-%{version}.tar.gz
Requires: firewalld
BuildArch: noarch

%description
Security hardening scripts, firewall configurations, and security
best practices for VaultOS. Includes post-installation hardening
and ongoing security maintenance tools.

%prep
%setup -q

%build
# No build step needed

%install
# Install security hardening script
install -d %{buildroot}%{_datadir}/vaultos/scripts
install -m 755 hardening.sh %{buildroot}%{_datadir}/vaultos/scripts/hardening.sh

# Install security documentation
install -d %{buildroot}%{_docdir}/%{name}
install -m 644 README.md %{buildroot}%{_docdir}/%{name}/README.md

# Install SELinux policies (if available)
if [ -d selinux ]; then
    install -d %{buildroot}%{_datadir}/selinux/packages
    install -m 644 selinux/*.pp %{buildroot}%{_datadir}/selinux/packages/ || true
fi

%post
# Run hardening script on installation
if [ -f %{_datadir}/vaultos/scripts/hardening.sh ]; then
    %{_datadir}/vaultos/scripts/hardening.sh || true
fi

%files
%{_datadir}/vaultos/scripts/hardening.sh
%{_docdir}/%{name}/README.md
%{_datadir}/selinux/packages/*.pp

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of security hardening package
- Added firewall configuration
- Added kernel security parameters
- Added automatic security updates
- Added SSH security hardening

