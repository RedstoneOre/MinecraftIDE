#! /bin/bash
[ -v MCEDITOR_INC_base_str ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Base.String Operations loaded'
	MCEDITOR_INC_base_str=
	function connectWithNull {
		local st=
		for i;do
			[ "$st" ] || {
				echo -en '\0'
				st=1
			}
			echo -n "$i"
		done
	}
}
