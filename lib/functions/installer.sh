## INSTALLER MODULE ##

# Extract a cab file in quiet mode
# (also lower case every file)
function extractCABs {
	local tmp="cabextract -Lq"
	local num=1
	local logfile="$TMPDIR/cabextract.log"

	while [ $num -le $# ]; do
		tmp="$tmp \"$(eval echo \${$num})\""
		num=$((num+1))
	done

	eval $tmp &> $logfile
	if [ $? != 0 ]; then
		cat "$logfile" && rm "$logfile"
		error An error occured when trying to cabextract some files.
	fi
	cat "$logfile" | debugPipe
	rm "$logfile"
}

# Generate reg and install it
# $1 ie version
function install_home_page {
	local temp="$TMPDIR/homepage.reg"

	get_start_page $1
	cat <<END > "$temp"
[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main]
"First Home Page"="${START_PAGE}"
"Start Page"="${START_PAGE}"

[HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer\Main]
"Default_Page_URL"="${START_PAGE}"
"Default_Search_URL"="http://www.google.com"
"Search Page"="http://www.google.com"
"Start Page"="${START_PAGE}"
END
	add_registry "$temp"
	rm "$temp"
}

function clean_tmp {
	rm -rf "$BASEDIR"/tmp/*
	rm -rf "$TMPDIR/*"
}

# Portable creation of temporary file
function create_temp_file {
	mktemp 2> /dev/null && return 0
	tempfile 2> /dev/null && return 0
	return 1
}

# Determine how to run a specific IE
# $1 IE Version
function run_ie {
	cd
	if which ie$1 | grep -q "$BINDIR/ie$1" 2> /dev/null; then
		echo " ie$1"
	else
		local l=$BINDIR/ie$1
		echo " ${l//\/\//\/}"
	fi
}

