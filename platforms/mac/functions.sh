# IEs4Mac
# Override some functions to work with Mac
# All functions *should* be declared using 'function' keyword.
# All global variables used by functions should have function name in their name.


function I {
	debug "Hi, I'm a Mac"
	echo IEs4Mac
}

function init_variables {
	export DARWIN=1
	export PLATFORM="mac"
	export TMPDIR="/tmp/ies4linux"
	
	export BASEDIR="$HOME/Applications/IEs 4 Mac/.ies4mac"
	export BINDIR="$HOME/Applications/IEs 4 Mac/"
	export IES4LINUX_MODE="automatic"
	export DARWIN_DOWNLOAD_CABEXTRACT=0
}

function pre_install {
	# Download cabextract to darwin #
	if [ "$DARWIN_DOWNLOAD_CABEXTRACT" = "1" ]; then
		section Getting cabextract
		
		subsection Downloading from tatanka.com.br:
			download http://www.tatanka.com.br/ies4mac/downloads/cabextract-1.2-macintel.zip
		
		subsection Extracting cabextract.zip
			rm -rf "$BASEDIR/cabextract"
			mkdir "$BASEDIR/cabextract"
			cd "$BASEDIR/cabextract/"
			unzip -Lqq "$DOWNLOADDIR/cabextract-1.2-macintel.zip"
			export PATH="$BASEDIR/cabextract/":$PATH
			which cabextract &> /dev/null || error "Download cabextract didn't work"
		ok
	fi
}

# $1 ie version
# $2 (optional) firstrun
function get_start_page {
	local url="http://www.tatanka.com.br/ies4mac/startpage?lang=$TRANSLATION_LOCALE&ieversion=$1"
	if [ "$2" = "firstrun" ]; then
		url="$url&firstrun=true"
	fi
	export START_PAGE="$url"
}

# Create all shortcuts: .ies4linux/bin/$1, bin/$1 and Desktop icon
# $1 excutable name
# $2 IE version
function createShortcuts {
	# On Mac, do not use BINDIR (yet)

	touch "$BASEDIR/$1/.firstrun"
	rm -f "$BASEDIR/bin/$1"
	get_start_page $1 firstrun
	mkdir -p "$BASEDIR/bin"

        cat << END > "$BASEDIR/bin/$1"
#!/usr/bin/env bash
# IEs 4 Mac script to run $1 - http://tatanka.com.br/ies4mac

debugPipe() {
	while read line; do [ "\$DEBUG" = "true" ] && echo \$line; done
}

cd
export PATH="$PATH"
export WINEPREFIX="$BASEDIR/$1"

# TODO do we need that?
open-x11

if [ -f "$BASEDIR/$1/.firstrun" ]; then
        rm "$BASEDIR/$1/.firstrun"
        ( wine "$BASEDIR/$1/$DRIVEC/Program Files/Internet Explorer/IEXPLORE.EXE" "${START_PAGE}" 2>&1 ) | debugPipe
else
        ( wine "$BASEDIR/$1/$DRIVEC/Program Files/Internet Explorer/IEXPLORE.EXE" "\$@" 2>&1 ) | debugPipe
fi
END
        chmod +x "$BASEDIR/bin/$1"
	ln -sf "$BASEDIR/bin/$1" "$BINDIR/$1"

	# TODO create .app shortcuts
}

function post_install {
	rm -rf "$BASEDIR/cabextract"
}


### Overwrite some functions
function find_wine {
	WINEHOME=$("$PLATFORMDIR"/whereiswine.sh)
	[ "$WINEHOME" = "" ] && error "$(I) couldn't find wine or darwine"
	export PATH="$WINEHOME":$PATH
	export WINEHOME
	wine --version 2>&1  | grep -q "0.9." || warning Your wine is too old. Please update it.
}

function find_cabextract {
	which cabextract &> /dev/null || export DARWIN_DOWNLOAD_CABEXTRACT=1
}

function getFileSize {
	ls -laF "$1" | awk '{print $5}'
	return 0
}

# Darwin does not have pidof, so we make a ingenue one
# $1 program to look for
function pidof {
	ps | grep "$1" | head -n 1 | awk '{print $1}'
}

