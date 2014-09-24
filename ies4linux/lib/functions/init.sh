## INIT MODULE ##

# Find where wine is
function find_wine {
	[ -f "`which wine`" ] || error You need to install wine first
	wine --version 2>&1  | grep -q "0.9." || warning Your wine is too old. Please update it.
}

# check for cabextract
function find_cabextract {
	[ -f "`which cabextract`" ] || error You need to install cabextract first
	cabextract --version | grep -q "1."   || error Your cabextract is too old, update it.
}

# check for wget or curl
function find_download_program {
	if [ -f "`which wget`" ]; then
		export HASWGET=1
	elif [ -f "`which curl`" ]; then
		export HASCURL=1
	else
		error Please install wget first
	fi
}

function find_unzip {
	[ -f "`which unzip`" ] || error "$(I) couldn't find unzip"
}

# Loads any file with environment variables
# $1 the file to load
function load_variables_file {
	grep -v -e "^#" -e "^[[:space:]]*$" "$1" | sed -e 's/^/export /g;s/$/;/g' 2> /dev/null
}

function load_default_language { 
	eval $(load_variables_file "$MESSAGE_FILE_FULLPATH")
}

