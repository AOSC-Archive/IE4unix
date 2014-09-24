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
	
	export BASEDIR="$HOME/Library/Application Support/IEs4Mac/"
	export BINDIR="$HOME/Library/Application Support/IEs4Mac/bin"
	export DOWNLOADDIR="$HOME/Library/Application Support/IEs4Mac/downloads"
	export TMPDIR="$HOME/Library/Application Support/IEs4Mac/tmp"
	
	export IES4LINUX_MODE="automatic"
	export DARWIN_DOWNLOAD_CABEXTRACT=0
	export CREATE_DESKTOP_ICON=0
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
			[ -f "`which cabextract`" ] || error "Download cabextract didn't work"
		ok
	fi
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

function post_install {
	rm -rf "$BASEDIR/cabextract"
}

### Overwrite some functions
function find_wine {
	WINEHOME="$("$PLATFORMDIR"/whereiswine)"
	[ "$WINEHOME" = "" ] && error "$(I) couldn't find wine or darwine"
	export PATH="$WINEHOME":$PATH
	export WINEHOME
	wine --version 2>&1  | grep -q "0.9." || warning Your wine is too old. Please update it.
}

function find_cabextract {
	[ -f "`which cabextract`" ] || export DARWIN_DOWNLOAD_CABEXTRACT=1
}

function getFileSize {
	ls -laF "$1" | awk '{print $5}'
	return 0
}

# Darwin does not have pidof, so we make a ingenue one
# $1 program to look for
function pidof {
	ps x | grep "$1" | head -n 1 | awk '{print $1}'
}

# Darwin does not have killall9, so we fake one
# (thanks to Mike Kronenberg)
function killall9 {
	if [ $# -eq 0 ]; then
		echo "Usage: killall9 NAME"
		exit
	fi

	PIDSTT=$(eval "ps x | grep $1 | awk '{print \$1}'")
	for PID in $PIDSTT;
	do
		if (ps -p $PID | grep $PID) &>/dev/null; then
		    if kill -9 $PID; then
		        echo "Killed $PID"
		    else
		        echo "could not kill $PID"
		    fi
		fi
	done
}

# Create app bundle
# $1 excutable name (ex. ie6)
# $2 IE version (ex. 6.0)
function createShortcuts {    
    local appfolder="$TMPDIR/ies4mac-bundles/Internet Explorer $2.app/"
	
    rm -rf "$appfolder" > /dev/null
    mkdir -p "$appfolder"
    
    cp -PR "$PLATFORMDIR/base.app/Contents" "$appfolder"
    mv "$BASEDIR/$1/" "$appfolder/Contents/Resources/dotwine"
    cp "$PLATFORMDIR/whereiswine" "$appfolder/Contents/Resources/"
    
    # TODO review this
    sed 's/BUNDLENAME/Internet Explorer '$2'/;s/IEVER/'$1'/;s/IES4MACVER/2.99.1/' "$PLATFORMDIR/base.app/Contents/Info.plist" > "$appfolder/Contents/Info.plist"
    #sed 's/WHICHINTERNETEXPLORER/'$1'/' "$PLATFORMDIR/base.app/Contents/Resources/start.sh" > "$appfolder/Contents/Resources/start.sh"

# TODO do we need freetype here??
#   [ "$INSTALLFONTANTIALIASING" = "0" ] && {
#        sed 's/export LD_LIBRARY_PATH/#export LD_LIBRARY_PATH/' ~/Desktop/Internet\ Explorer\ $2.app/Contents/Resources/start.sh > ~/Desktop/Internet\ Explorer\ $2.app/Contents/Resources/start.sh2
#        mv -f ~/Desktop/Internet\ Explorer\ $2.app/Contents/Resources/start.sh2 ~/Desktop/Internet\ Explorer\ $2.app/Contents/Resources/start.sh
#    }

	get_start_page $1 firstrun
	rm -rf "$HOME/Desktop/Internet Explorer $2.app/"
	mv "$appfolder" "$HOME/Desktop/Internet Explorer $2.app/"
}

