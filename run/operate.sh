#! /bin/bash
[ -v MCEDITOR_INC_operate ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Operations loaded'
	MCEDITOR_INC_operate=
	. "$dirp"/map.sh
	. "$dirp"/block.sh
	. "$dirp"/print.sh
	. "$dirp"/container.sh
	. "$dirp"/command.sh
	function Operate_MoveUpwards {
		[ "`getChar "$px" "$[py-1]"`" != BOL ] && {
			move 0 -1; ismove=1
			UpdScreen[0]=1
			opsuc=1
			ScheduleScreenUpdate 0
		}
	}
	function Operate_MoveLeft {
		move -1 0; ismove=1;opsuc=1
		ScheduleScreenUpdate 0
	}
	function Operate_MoveDownwards {
		move 0 1; ismove=1;opsuc=1
		ScheduleScreenUpdate 0
	}
	function Operate_MoveRight {
		move 1 0; ismove=1;opsuc=1
		ScheduleScreenUpdate 0
	}
	function Operate_Jump {
		[ "$power" -ge 20 ] && {
			# [ "`getChar "$px" "$[py-1]"`" != BOL ] && 
			move 0 -1
			canceldrop="$[canceldrop+1]"
			power="$[power-20]"
			opsuc=1 ismove=1
			ScheduleScreenUpdate 0
		}
	}

	function Operate_MoveFocusUpwards {
		GetScreenLeftUpperCorner "$px" "$py"
		ScheduleScreenUpdate "$[focy-(ScrUpper)+1]"
		movefocus 0 -1; opsuc=1
		ScheduleScreenUpdate "$[focy-(ScrUpper)+1]"
	}
	function Operate_MoveFocusLeft {
		GetScreenLeftUpperCorner "$px" "$py"
		movefocus -1 0; opsuc=1
		ScheduleScreenUpdate "$[focy-(ScrUpper)+1]"
	}
	function Operate_MoveFocusDownwards {
		GetScreenLeftUpperCorner "$px" "$py"
		ScheduleScreenUpdate "$[focy-(ScrUpper)+1]"
		movefocus 0 1; opsuc=1
		ScheduleScreenUpdate "$[focy-(ScrUpper)+1]"
	}
	function Operate_MoveFocusRight {
		GetScreenLeftUpperCorner "$px" "$py"
		movefocus 1 0; opsuc=1
		ScheduleScreenUpdate "$[focy-(ScrUpper)+1]"
	}

	function Operate_Nothing {
		opsuc=1
	}
	function Operate_SwitchHotbar {
		lselhotbar="$selhotbar" selhotbar="$1"
		opsuc=1
	}
	function Operate_Dig {
		 [ "`getChar "$focx" "$focy"`" != ' ' ] && dig "$focx" "$focy" && {
			opsuc=1;isdig=1
		}
	}
	function Operate_UseBlock {
		matchChar "$focx" "$focy" ' ' && {
			[ "${invc["$selhotbar"]}" -ge 1 ] && {
				place "$focx" "$focy" "${inv["$selhotbar"]}" && {
					InvTake inv "$selhotbar" 1
					opsuc=1 isdig=1
				}
			}
			true
		} || {
			UseBlock "$focx" "$focy"
			opsuc=1
		}
	}
	function Operate_OpenInventory {
		invopen=1 opsuc=1
	}

	function Operate_Command {
		local cmd=
		echo -n 'Command: '
		stty echo
		read -r cmd
		stty -echo
		RunCommand "$cmd"
	}
	# ^C when inputting
	function Operate_ { :;}

	function OperateInv_InvMU {
		((invselected-9>=0)) && ((invselected-=9))
	}
	function OperateInv_InvMD {
		((invselected+9<PLAYERINV_INVSIZE)) && ((invselected+=9))
	}
	function OperateInv_InvML {
		((invselected-1>=0)) && ((invselected-=1))
	}
	function OperateInv_InvMR {
		((invselected+1<PLAYERINV_INVSIZE)) && ((invselected+=1))
	}
	function OperateInv_InvLC {
		InvSwap inv $invselected inv $PLAYERINV_CURSOR
	}
	function OperateInv_InvSwitchHotbar {
		[ -n "${inv[$PLAYERINV_CURSOR]}" ] && {
			InvSwap inv $PLAYERINV_CURSOR inv $1
			true
		} || {
			InvSwap inv $invselected inv $1
		}
	}
	function OperateInv_InvClose {
		invopen=0
	}
	
	function Operate_Leave {
		opsuc=1 end=1
	}
}
