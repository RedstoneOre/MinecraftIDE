[ -v MCEDITOR_INC_base_check ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Base.Checking loaded'
	MCEDITOR_INC_base_check=
	function IsNumber {
		{ ! [[ "$1" =~ [^0-9] ]] && [ "${1:0:1}" != 0 ];} || { [ "${1:0:1}" == - ] && ! [[ "${1:1}" =~ [^0-9] ]] && [ "${1:1:1}" != 0 ]; } || [ "$1" == 0 ]
	}
	function IsIdName {
		[ -n "$1" ] && ! [[ "$1" =~ [^0-9a-zA-Z_/.:] ]]
	}
	function IsFileName {
		[ -n "$1" ] && ! [[ "$1" =~ [/$'\n'] ]] && [ "$1" != '.' ] && [ "$1" != '..' ]
	}
}
