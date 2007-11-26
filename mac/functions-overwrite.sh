# IEs4Mac
# Override some functions to work with Mac
# All functions *should* be declared using 'function' keyword.
# All global variables used by functions should have function name in their name.


function I {
	debug "Hi, I'm a Mac"
	echo IEs4Mac
}

function init_variables {
	export BASEDIR="$HOME/Applications/IEs 4 Mac/"
	export BINDIR="$BASEDIR/bin"
	export IES4LINUX_MODE="automatic"
	export DARWIN_DOWNLOAD_CABEXTRACT=0
}

function find_wine {
	WINEHOME=$("$IES4LINUX"/mac/whereiswine.sh)
	[ "$WINEHOME" = "" ] && error "$(I) couldn't find wine or darwine"
	export PATH=$WINEHOME:$PATH
	wine --version 2>&1  | grep -q "0.9." || warning $MSG_WARNING_OLDWINE
}

function find_cabextract {
	which cabextract &> /dev/null || export DARWIN_DOWNLOAD_CABEXTRACT=1
}

function pre_install {
	# Download cabextract to darwin ###############################################
	if [ "$DARWIN_DOWNLOAD_CABEXTRACT" = "1" ]; then
		section Getting cabextract
		subsection $MSG_DOWNLOADING_FROM tatanka.com.br:
			download http://www.tatanka.com.br/ies4mac/downloads/cabextract-1.2-macintel.zip
		subsection Extracting cabextract.zip
			mkdir "$BASEDIR/cabextract"
			cd "$BASEDIR/cabextract/"
			unzip -Lqq "$DOWNLOADDIR/cabextract-1.2-macintel.zip"
			export PATH="$BASEDIR/cabextract/":$PATH
		ok
	fi
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
# IEs 4 Mac script to run $1 - http://tatanka.com.br/ies4linux

debugPipe() {
	while read line; do [ "\$DEBUG" = "true" ] && echo \$line; done
}

cd
export WINEPREFIX="$BASEDIR/$1"

if [ -f "$BASEDIR/$1/.firstrun" ]; then
        rm "$BASEDIR/$1/.firstrun"
        ( open-x11 wine "$BASEDIR/$1/$DRIVEC/Program Files/Internet Explorer/IEXPLORE.EXE" "${START_PAGE}" 2>&1 ) | debugPipe
else
        ( open-x11 wine "$BASEDIR/$1/$DRIVEC/Program Files/Internet Explorer/IEXPLORE.EXE" "\$@" 2>&1 ) | debugPipe
fi
END
        chmod +x "$BASEDIR/bin/$1"

	# TODO create .app shortcuts
}

###############################################################################################################
# Export all functions so subshells can access them
for fn in $(grep "^function" "$IES4LINUX"/mac/functions-overwrite.sh | sed -e 's/function[[:space:]]*//g;s/{//g'); do
	export -f $fn
done
