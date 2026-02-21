
#! /bin/bash
[ -v MCEDITOR_INC_command ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Command parsing loaded'
	MCEDITOR_INC_command=
	. "$dirp"/dimension.sh
	. "$dirp"/container.sh
	. "$dirp"/map.sh
	function RunCommand {
		local c="${cmd%% *}" a="${cmd#* }"
		case "$c" in
			dim) dim=`GetDimensionID "$a"`;;
			give) InvAdd inv "$selhotbar" "$a" 1;;
			set)
				echo
				echo -n "Set ($focx, $focy): from '"
				getChar "$focx" "$focy"
				echo "' to $a"
				setChar "$focx" "$focy" "$a"
				;;
			*) ;;
		esac
	}
}
