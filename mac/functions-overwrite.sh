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

###############################################################################################################
# Export all functions so subshells can access them
for fn in $(grep "^function" "$IES4LINUX"/mac/functions-overwrite.sh | sed -e 's/function[[:space:]]*//g;s/{//g'); do
	export -f $fn
done
