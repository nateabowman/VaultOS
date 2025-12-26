# VaultOS Themes RPM Spec File
# GTK, Qt, and terminal themes for VaultOS

%define name vaultos-themes
%define version 1.0.0
%define release 1

Summary: Fallout-themed GTK, Qt, and terminal themes for VaultOS
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
License: GPLv3
Group: User Interface/Desktops
Source0: %{name}-%{version}.tar.gz
BuildRequires: gtk3, gtk4, qt5-qtbase-devel

%description
VaultOS themes package containing GTK3, GTK4, and Qt themes
with Fallout aesthetic including Pip-Boy green and Vault-Tec
color schemes.

%prep
%setup -q

%build
# No build step needed for themes

%install
# Install GTK themes
install -d %{buildroot}%{_datadir}/themes/VaultOS/gtk-3.0
install -m 644 gtk/vaultos-gtk3.css %{buildroot}%{_datadir}/themes/VaultOS/gtk-3.0/gtk.css
install -m 644 gtk/vaultos-gtk3.css %{buildroot}%{_datadir}/themes/VaultOS/gtk-3.0/gtk-dark.css

install -d %{buildroot}%{_datadir}/themes/VaultOS/gtk-4.0
install -m 644 gtk/vaultos-gtk4.css %{buildroot}%{_datadir}/themes/VaultOS/gtk-4.0/gtk.css

install -m 644 gtk/index.theme %{buildroot}%{_datadir}/themes/VaultOS/index.theme

# Install Qt theme
install -d %{buildroot}%{_datadir}/vaultos/themes
install -m 644 qt/vaultos.qss %{buildroot}%{_datadir}/vaultos/themes/vaultos.qss

# Install color schemes
install -d %{buildroot}%{_datadir}/vaultos/colors
install -m 644 colors/*.colors %{buildroot}%{_datadir}/vaultos/colors/

%files
%{_datadir}/themes/VaultOS/
%{_datadir}/vaultos/themes/
%{_datadir}/vaultos/colors/

%changelog
* Mon Jan 01 2024 VaultOS Team <team@vaultos.org> - 1.0.0-1
- Initial release of VaultOS themes

