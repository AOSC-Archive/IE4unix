## WINE MODULE ##

# Call wineprefixcreate
function create_wine_prefix {
	if [ -f "`which wineprefixcreate`" ]; then
		( wineprefixcreate 2>&1 ) | debugPipe
	else
		error Your wine does not have wineprefixcreate installed. Maybe because it is too old.
	fi
}

# Register a dll
# $1 dll to be registered
function register_dll {
	debug Registering DLL: $1
	(WINEDLLOVERRIDES="regsvr32.exe=b" wine regsvr32 /i "$1" 2>&1) | debugPipe
}

# Add a registry file
# $1 reg file to be registered
function add_registry {
	debug Add $1 to registry
	(wine regedit "$1" 2>&1) | debugPipe
}

# Process an inf file
# $1 Inf file to process
function run_inf_file {
	debug Process INF $1
	( wine rundll32 setupapi.dll,InstallHinfSection DefaultInstall 128 "$1" 2>&1) | debugPipe
}

function reboot_wine {
	debug Rebooting wine bottle
	(wineboot 2>&1) | debugPipe
}
function kill_wineserver {
	debug Kill wineserver
	( (
	wineserver -k || {
		killall wine
		killall wineserver
	}
	) 2>&1) | debugPipe

}
function set_wine_prefix {
	export WINEPREFIX="$1"
}

