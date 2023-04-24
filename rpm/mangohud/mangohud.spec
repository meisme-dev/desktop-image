%global appname MangoHud

%global imgui_ver       1.81
%global imgui_wrap_ver  1

# Tests requires bundled stuff. Disable for now.
%bcond_with tests

Name:           mangohud
Version:        0.6.9.1
Release:        %autorelease
Summary:        Vulkan overlay layer for monitoring FPS, temperatures, CPU/GPU load and more

License:        MIT
URL:            https://github.com/flightlessmango/MangoHud
Source0:        %{url}/archive/v0.6.9-1/%{name}-%{version}.tar.gz
Source1:        https://github.com/ocornut/imgui/archive/v%{imgui_ver}/imgui-%{imgui_ver}.tar.gz
Source2:        https://wrapdb.mesonbuild.com/v1/projects/imgui/%{imgui_ver}/%{imgui_wrap_ver}/get_zip#/imgui-%{imgui_ver}-%{imgui_wrap_ver}-wrap.zip

# MangoHud switched to bundled vulkan-headers since 0.6.9 version. This rebased
# upstream patch which reverts this change.
# https://github.com/flightlessmango/MangoHud/commit/bc282cf300ed5b6831177cf3e6753bc20f48e942
Patch0:         mangohud-0.6.9-use-system-vulkan-headers.patch

BuildRequires:  appstream
BuildRequires:  dbus-devel
BuildRequires:  gcc-c++
BuildRequires:  git-core
BuildRequires:  glew-devel
BuildRequires:  glfw-devel
BuildRequires:  glslang-devel
BuildRequires:  libappstream-glib
BuildRequires:  mesa-libGL-devel
BuildRequires:  meson >= 0.60
BuildRequires:  python3-mako
BuildRequires:  spdlog-devel

BuildRequires:  pkgconfig(nlohmann_json)
BuildRequires:  pkgconfig(vulkan)
BuildRequires:  pkgconfig(wayland-client)
BuildRequires:  pkgconfig(x11)

%if %{with tests}
BuildRequires:  libcmocka-devel
%endif

Requires:       hicolor-icon-theme
Requires:       vulkan-loader%{?_isa}

Recommends:     (mangohud(x86-32) if glibc(x86-32))

Suggests:       goverlay

Provides:       bundled(imgui) = %{imgui_ver}

%global _description %{expand:
A modification of the Mesa Vulkan overlay. Including GUI improvements,
temperature reporting, and logging capabilities.

To install GUI front-end:

  # dnf install goverlay}

%description %{_description}


%prep
%autosetup -n %{appname}-0.6.9-1 -p1
%setup -qn %{appname}-0.6.9-1 -DTa1
%setup -qn %{appname}-0.6.9-1 -DTa2

mkdir subprojects/imgui
mv imgui-%{imgui_ver} subprojects/


%build
%meson \
    -Dinclude_doc=true \
    -Duse_system_spdlog=enabled \
    -Duse_system_vulkan=enabled \
    -Dwith_wayland=enabled \
    -Dwith_xnvctrl=disabled \
    -Dmangoapp=true \
    %if %{with tests}
    -Dtests=enabled \
    %else
    -Dtests=disabled \
    %endif
    %{nil}
%meson_build


%install
%meson_install


%check
# https://github.com/flightlessmango/MangoHud/issues/812
%dnl appstream-util validate-relax --nonet %{buildroot}%{_metainfodir}/*.xml


%files
%license LICENSE
%doc README.md
%{_bindir}/%{name}*
%{_datadir}/icons/hicolor/scalable/*/*.svg
%{_datadir}/vulkan/implicit_layer.d/*Mango*.json
%{_docdir}/%{name}/%{appname}.conf.example
%{_libdir}/%{name}/
%{_mandir}/man1/%{name}.1*
%{_metainfodir}/*.metainfo.xml

# fix later
/usr/bin/mangoapp
/usr/lib/debug/usr/bin/mangoapp-0.6.9.1-1.fc38.x86_64.debug
/usr/share/man/man1/mangoapp.1.gz



%changelog
%autochangelog
