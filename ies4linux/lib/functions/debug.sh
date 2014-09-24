## DEBUG MODULE ##

# Print a message if debug is on
# $* Message to be printed
function debug { 
	[ "$DEBUG" = "true"  ] && echo "DEBUG: $*"
}

# Pipe to read messages and print them if debug is on
function debugPipe {
	while read line; do
		debug $line
	done
}

function isNotDebug {
	[ "$DEBUG" = "true"  ] && return 0
	return 1
}

# Initialize Debug module
[ "$DEBUG" != true ] && DEBUG=false
debug Debug on

