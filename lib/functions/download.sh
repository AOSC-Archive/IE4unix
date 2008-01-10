## DOWNLOAD MODULE ##

# Download something
# $1 url do be downloaded
function download {
	local URL=$1
	local FILENAME=$(echo $URL | sed -e "s/.*\///")
	local DIR=$(echo $URL | grep $URL_IE6_CABS | sed -e "s/.*W98NT42KMeXP\//ie6\//;s/\/[^\/]*$/\//")
	local file="$DOWNLOADDIR/$DIR$FILENAME"

	line=$(grep -e "^${DIR}${FILENAME}" "$SCRIPTDIR/etc/files")
	local correctsize=$(echo $line|awk '{print $2}')
	local correctmd5=$(echo $line|awk '{print $3}')

	echo -n "   $FILENAME"

	# Download file if (1) doesn't exist or (2) download was interrupted before
	if [ ! -f "$file" ] || [ "$(getFileSize "$file")" -lt "$((correctsize + 0))" ]; then
		printDownloadPercentage $FILENAME 0
		touch "$file"

		local useragent="Mozilla/4.0 (compatible; MSIE 6.0; Windows 98)"
		if [ "$HASWGET" = "1" ]; then
			pid=$(wget -q -b -t 1 -T 5 -U "$useragent" -o /dev/null $URL $WGETFLAGS -O "$file" | sed -e 's/[^0-9]//g')
		elif [ "$HASCURL" = "1" ]; then
			( curl -s -A "$useragent" "$URL" -o "$file" & )
			pid="$(pidof curl)"
		else
			error no download program!
		fi
		debug Download PID=$pid
		
		while ps -p $pid | grep $pid &> /dev/null; do
			if [ "$correctsize" != "" ];then
				du=$(getFileSize "$file")
				percent=$(( 100 * $du / $correctsize ))
			else
				percent=-
			fi
			printDownloadPercentage $FILENAME $percent
			sleep 0.3
		done

		# After wget ends, see if (1) 404 or (2) stoped
		local finalsize=$(getFileSize "$file")
		if [ "$finalsize" = "0" ]; then
			debug File $FILENAME not found
			rm "$file"
			return 1
		fi
		if [ "$finalsize" -lt "$((correctsize + 0))" ]; then
			error An error ocurred when downloading. Please run IEs4Linux again. Corrupted file: $DIR$FILENAME
		fi

		printDownloadPercentage $FILENAME 100
	fi
	echo

	# Check file size and md5
	size=$(getFileSize "$file")
	md5=$(getMD5 "$file")
	debug ${DIR}${FILENAME}: correctsize $correctsize correctmd5 $correctmd5
	debug ${DIR}${FILENAME}: size $size md5 $md5

	if [ "$correctmd5" != "" ] ; then
		if [ "$size" != "$correctsize" ] || [ "$md5" != "$correctmd5" ]; then
			rm "$file"
			error An error ocurred when downloading. Please run IEs4Linux again. Corrupted file: $DIR$FILENAME
		fi
	fi
}

# $1 FILENAME
# $2 PERCENTAGE
export download_status_bar=0
function printDownloadPercentage {
	# Print a space
	echo -ne "\r   "

	# Print percentage or bar
	if [ $2 = "-" ]; then
		if [ $download_status_bar = 0 ]; then
			echo -n "-    "
		elif [ $download_status_bar = 1 ]; then
			echo -n "\    "
		elif [ $download_status_bar = 2 ]; then
			echo -n "|   "
		else
			echo -n "/    "
			download_status_bar=-1
		fi
		download_status_bar=$(($download_status_bar + 1))
	else
		if [ $2 -lt 10 ]; then # 0-9
			echo -n "${2}%   "
		elif [ $2 -lt 100 ]; then # 10-99
			echo -n "${2}%  "
		else # 100
			echo -n "${2}% "
		fi
	fi

	# Print filename
	echo -n "$1"
}

# Portable md5 calculator
# $1 file
function getMD5 {
	if which md5sum &> /dev/null;then
		MD5SUM=$(md5sum "$1")
	else
		MD5SUM=$(md5 -q "$1")
	fi
	echo $MD5SUM | awk '{print $1}'
}

# Portable file size calculator
# $1 file name
function getFileSize {
	stat '-c' '%s' "$1" 2> '/dev/null' && return 0

	du -b "$1" &> /dev/null && {
		du -b "$1" | awk '{print $1}'
		return 0
	}

	wc '-c' "$1" &> '/dev/null' && {
		wc '-c' "$1"
		return 0
	}

	ls '--block-size=1' '-l' "$1" &> '/dev/null' && {
		ls -laF --block-size=1 "$1" | awk '{print $5}'
		return 0
	}

	ls '-l' "$1" &> '/dev/null' && { # for OSX
		ls -laF "$1" | awk '{print $5}'
		return 0
	}

	return 1
}

# Download something from Evolt, with mirror selection
# $1 Evolt path
function downloadEvolt {
	local EVOLT_MIRROR1=http://www.mirrorservice.org/sites/browsers.evolt.org/browsers
	local EVOLT_MIRROR2=http://planetmirror.com/pub/browsers
	local EVOLT_MIRROR3=http://download.mirror.ac.uk/mirror/ftp.evolt.org

	if ! download $EVOLT_MIRROR1/$1 ; then
		echo -ne "\r "
		debug Trying Evolt Mirror 2
		if ! download $EVOLT_MIRROR2/$1 ; then
			debug Trying Evolt Mirror 3
			if ! download $EVOLT_MIRROR3/$1 ; then
				error Could not find a suitable Evolt mirror
			fi
		fi
	fi
}

