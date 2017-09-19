# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit gnome2 flag-o-matic autotools

DESCRIPTION="Deepin fork version of mutter"
HOMEPAGE="https://github.com/linuxdeepin/deepin-mutter"
SRC_URI="https://github.com/linuxdeepin/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"

IUSE="+introspection +kms test wayland"
REQUIRED_USE="
	wayland? ( kms )
"

KEYWORDS="~amd64 ~x86"

# libXi-1.7.4 or newer needed per:
# https://bugzilla.gnome.org/show_bug.cgi?id=738944
COMMON_DEPEND="
	>=x11-libs/pango-1.2[X,introspection?]
	>=x11-libs/cairo-1.10[X]
	>=x11-libs/gtk+-3.19.8:3[X,introspection?]
	>=dev-libs/glib-2.36.0:2[dbus]
	>=media-libs/clutter-1.25.3:1.0[X,introspection?]
	>=media-libs/cogl-1.17.1:1.0=[introspection?,jpeg]
	>=media-libs/libcanberra-0.26[gtk3]
	>=x11-libs/startup-notification-0.7
	>=x11-libs/libXcomposite-0.2
	>=gnome-base/gsettings-desktop-schemas-3.19.3[introspection?]
	gnome-base/gnome-desktop:3=
	>sys-power/upower-0.99:=

	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	>=x11-libs/libXcomposite-0.2
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	>=x11-libs/libXi-1.7.4
	x11-libs/libXinerama
	>=x11-libs/libXrandr-1.5
	x11-libs/libXrender
	x11-libs/libxcb
	x11-libs/libxkbfile
	>=x11-libs/libxkbcommon-0.4.3[X]
	x11-misc/xkeyboard-config

	gnome-extra/zenity

	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
	kms? (
		dev-libs/libinput
		>=media-libs/clutter-1.20[egl]
		media-libs/cogl:1.0=[kms]
		>=media-libs/mesa-10.3[gbm]
		sys-apps/systemd
		virtual/libgudev
		x11-libs/libdrm:= )
	wayland? (
		>=dev-libs/wayland-1.6.90
		>=dev-libs/wayland-protocols-1.1
		>=media-libs/clutter-1.20[wayland]
		x11-base/xorg-server[wayland] )
"
DEPEND="${COMMON_DEPEND}
	dde-base/deepin-desktop-schemas
	>=dev-util/intltool-0.41
	sys-devel/gettext
	virtual/pkgconfig
	x11-proto/xextproto
	x11-proto/xineramaproto
	x11-proto/xproto
	test? ( app-text/docbook-xml-dtd:4.5 )
"
RDEPEND="${COMMON_DEPEND}
	!x11-misc/expocity
"
src_prepare() {

#	[[ $(gcc-major-version) < 5 ]] && epatch "${FILESDIR}"/"${PN}-3.20-fix-c99-mode-gcc49.patch" 
	epatch "${FILESDIR}/${PN}-3.20-include-math.patch"
	epatch "${FILESDIR}/${PN}-3.20-redefine_macro.patch"

	gnome2_src_prepare
}

src_configure() {
	[[ $(gcc-major-version) < 5 ]] && append-flags "-std=gnu99"
	./autogen.sh  --prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--libexecdir=/usr/$(get_libdir)/deepin-mutter \
		--disable-static \
		--disable-schemas-compile \
		--enable-sm \
		--with-libcanberra \
		--enable-compile-warnings=minimum \
		$(use_enable introspection) \
		$(use_enable kms native-backend) \
		$(use_enable wayland)
}
