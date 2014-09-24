# IEs4Linux
# Linux-specific functions needed everywhere.

function I {
	debug "Hi, I'm Linux"
	echo IEs4Linux
}

function init_variables {
	export LINUX=1
	export PLATFORM="linux"
}

function pre_install {
	echo a > /dev/null
}

function post_install {
	# Updates user menu
	# [ "$CREATE_MENU_ICON" = "1" ] && "$IES4LINUX"/lib/xdg-desktop-menu forceupdate

	# Show user how to run her IEs
	echo
	section "To run your IEs, type:"
	[ "$INSTALLIE6"  = "1" ] && run_ie 6
	[ "$INSTALLIE55" = "1" ] && run_ie 55
	[ "$INSTALLIE5"  = "1" ] && run_ie 5
	[ "$INSTALLIE1"  = "1" ] && run_ie 1
	[ "$INSTALLIE15" = "1" ] && run_ie 15
	[ "$INSTALLIE2"  = "1" ] && run_ie 2
	[ "$INSTALLIE3"  = "1" ] && run_ie 3
	[ "$INSTALLIE7"  = "1" ] && run_ie 7
	echo
}

# $1 ie version
# $2 (optional) firstrun
function get_start_page {
	local url="http://www.tatanka.com.br/ies4linux/startpage?lang=$TRANSLATION_LOCALE&ieversion=$1"
	if [ "$2" = "firstrun" ]; then
		url="$url&firstrun=true"
	fi
	export START_PAGE="$url"
}


# Create all shortcuts: .ies4linux/bin/$1, bin/$1 and Desktop icon
# $1 excutable name
# $2 IE version
function createShortcuts {
	touch "$BASEDIR/$1/.firstrun"
	rm -f "$BASEDIR/bin/$1" "$BINDIR/$1"
	get_start_page $1 firstrun
	mkdir -p "$BASEDIR/bin"
        cat << END > "$BASEDIR/bin/$1"
#!/usr/bin/env bash
# IEs 4 Linux script to run $1 - http://tatanka.com.br/ies4linux

debugPipe() {
	while read line; do [ "\$DEBUG" = "true" ] && echo \$line; done
}

cd
export WINEPREFIX="$BASEDIR/$1"

if [ -f "$BASEDIR/$1/.firstrun" ]; then
        rm "$BASEDIR/$1/.firstrun"
        ( wine "$BASEDIR/$1/$DRIVEC/Program Files/Internet Explorer/IEXPLORE.EXE" "${START_PAGE}" 2>&1 ) | debugPipe
else
        ( wine "$BASEDIR/$1/$DRIVEC/Program Files/Internet Explorer/IEXPLORE.EXE" "\$@" 2>&1 ) | debugPipe
fi
END
    chmod +x "$BASEDIR/bin/$1"
	ln -sf "$BASEDIR/bin/$1" "$BINDIR/$1"

	# Create launcher icon
	ICON_FILE="$BASEDIR"/ies4linux-$1.desktop
	cat << END > "$ICON_FILE"
[Desktop Entry]
Version=1.0
Exec=$BINDIR/$1
Icon=$BASEDIR/logo.png
Name=Internet Explorer $2
GenericName=Web Browser
Comment=MSIE $2 by IEs4Linux
Encoding=UTF-8
Terminal=false
Type=Application
Categories=Application;Network;
END
	
	[ "$DEBUG" = "true" ] && export XDG_UTILS_DEBUG_LEVEL=1
	if [ "$CREATE_DESKTOP_ICON" = "1" ]; then
		"$PLATFORMDIR"/xdg-desktop-icon install --novendor "$ICON_FILE"
	fi
	# menu creation is disabled
	#if [ "$CREATE_MENU_ICON" = "1" ]; then
	#	"$PLATFORMDIR"/xdg-desktop-menu install --noupdate --novendor "$ICON_FILE"
	#fi
}

