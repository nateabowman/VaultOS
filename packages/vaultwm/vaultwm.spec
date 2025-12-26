# VaultWM RPM Spec File
# Custom window manager for VaultOS

%define name vaultwm
%define version 1.0.0
%define release 1

Summary: VaultOS Fallout-themed Window Manager
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: System Environment/Window Managers
Source0: %{name}-%{version}.tar.gz
BuildRequires: gcc, make, libX11-devel
Requires: xorg-x11-server-Xorg

%description
VaultWM is a lightweight, Fallout-themed window manager for X11.
Features include tiling/floating modes, Pip-Boy-style status bar,
and keyboard-driven navigation with Fallout aesthetic.

%prep
%setup -q

%build
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

# Install desktop entry
install -d %{buildroot}%{_datadir}/xsessions
install -m 644 %{SOURCE1} %{buildroot}%{_datadir}/xsessions/vaultwm.desktop

# Install systemd service
install -d %{buildroot}%{_unitdir}
install -m 644 %{SOURCE2} %{buildroot}%{_unitdir}/vaultwm.service

%files
%{_bindir}/vaultwm
%{_datadir}/xsessions/vaultwm.desktop
%{_unitdir}/vaultwm.service

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of VaultWM

