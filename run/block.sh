#! /bin/bash
[ -v MCEDITOR_INC_block ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Block interacting header loaded'
	MCEDITOR_INC_block=
	. "$dirp"/map.sh
	. "$dirp"/block/piston.sh
	focx=0 focy=0 dip=0
	function dig {
		[ "$focx" == "$1" ] && [ "$focy" == "$2" ] && {
			dip="$[dip+1]"
			[ "$dip" -ge "$(getHardness `getChar "$focx" "$focy"`)" ] && {
				dip=0
				CreateEntity $ENTITY_ITEM `GetItemEntityData "$(getChar "$focx" "$focy")" 1` "$focx" "$focy" "$dim"
				setChar "$focx" "$focy" ' '
			}
			true
		} || {
			focx="$1" focy="$2" dip=0
		}
	}
	# place <x> <y> <Char>
	function place {
		[ "`getChar "$1" "$2"`" == ' ' ] && setChar "$1" "$2" "$3"
	}
	function movefocus {
		tpx="$1" tpy="$2"
		[ "$3" == s ] && {
			true
		} || {
			tpx="$[$1+focx]" tpy="$[$2+focy]"
		}
		[ "$tpx" -ge "$[px-2]" ] && [ "$tpx" -le "$[px+2]" ] &&
		[ "$tpy" -ge "$[py-2]" ] && [ "$tpy" -le "$[py+2]" ] && {
			focx="$tpx" focy="$tpy"
			return 0
		}
		return 1
	}
	function UseBlock {
		ublockt="`getChar "$1" "$2"`"
		case "$ublockt" in
			'#') UsePiston "$1" "$2" ;; #Piston
		esac
	}
}
