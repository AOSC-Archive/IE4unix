## OUTPUT MODULE ##

# Functions to print things
function warning {
	if [ "$NOCOLOR" = "0" ]; then
		echo -en "\E[31;1m";
		echo -e $*
		echo
		tput sgr0;
	else
		echo "!! $*"
	fi
}
function error {
	warning $*
	exit 1
}
function section {
	if [ "$NOCOLOR" = "0" ]; then 
		echo -e "\E[1m$*"; tput sgr0
	else
		echo "# $*"
	fi
}
function subsection {
	echo "  $*"
}
function subsubsection {
	echo "    $*"
}
function ok {
	if [ "$NOCOLOR" = "0" ]; then 
		echo -e "\E[34;1m[ OK ]\n"; tput sgr0
	else
		echo -e "[ OK ]\n"
	fi
}

