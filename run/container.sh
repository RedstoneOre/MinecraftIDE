#! /bin/bash
[ -v MCEDITOR_INC_container ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Container header loaded'
	MCEDITOR_INC_contatiner=
	. "$dirp"/print.sh
	selhotbar=0 lselhotbar=-1
	# InvInit <Container> <Size>
	#  initialize a container
	function InvInit {
		unset "$1" "${1}c" "${1}dispcache" "${1}size"
		declare -ag "$1=()"
		declare -ag "${1}c=()"
		declare -ag "${1}dispcache=()"
		declare -g "${1}size=$2"

		declare -n _inv="$1"
		declare -n _invc="${1}c"
		declare -n _invdispcache="${1}dispcache"
		for((i=0;i<$2;++i));do
			_inv[i]='' _invc[i]=0 _invdispcache[i]=''
		done
	}

	# InvPick <Container> <Type> [Count:1]
	#  pick up items
	#  return invPickRemaining as the remaining count
	function InvPick {
		local cnt="${3:-1}" i=
		declare -n _inv="$1"
		declare -n _invc="${1}c"
		declare -n _invdispcache="${1}dispcache"
		declare -n _invsize="${1}size"
		for((i=0;i<_invsize;++i));do
			invmaxstack=64
			[ "${_inv[i]:-$2}" == "$2" ] && [ "${_invc[i]}" -lt "$invmaxstack" ] && {
				_invdispcache[i]=''
				_inv[i]="$2"
				_invc[i]="$[${_invc[i]}+cnt]"
				[ "${_invc[i]}" -gt "$invmaxstack" ] && {
					cnt="$[${_invc[i]}-invmaxstack]"
					_invc[i]="$invmaxstack"
					true
				} || {
					break
				}
			}
		done
		invPickRemaining="$cnt"
	}
	# InvTake <Container> <Slot> <Num>
	#  return if successfully take the items
	#  when fail, do nothing
	function InvTake {
		declare -n _inv="$1"
		declare -n _invc="${1}c"
		declare -n _invdispcache="${1}dispcache"
		[ "${_invc[$2]}" -ge "$3" ] && {
			_invdispcache[$2]=''
			_invc[$2]="$[${_invc[$2]}-$3]"
			[ "${_invc[$2]}" == 0 ] && {
				_inv[$2]=''
			}
			return 0
		}
		return 1
	}
	# InvAdd <Container> <Slot> <Type> <Num>
	#  Add some item to a slot
	#  return fail if cannot add(type not match or too much to add) then do nothing
	function InvAdd {
		declare -n _inv="$1"
		declare -n _invc="${1}c"
		declare -n _invdispcache="${1}dispcache"
		invmaxstack=64
		[ "${_inv[$2]:-$3}" == "$3" ] && [ "$[${_invc[$2]}+$4]" -le "$invmaxstack" ] && {
			_invdispcache[$2]=''
			_invc[$2]="$[${_invc[$2]}+$4]"
			_inv[$2]="$3"
			return 0
		}
		return 1
	}

	# InvSwap <Container1> <Slot1> <Container2> <Slot2>
	function InvSwap {
		declare -n _inv="$1"
		declare -n _invc="${1}c"
		declare -n _invdispcache="${1}dispcache"
		declare -n _inv2="$3"
		declare -n _invc2="${3}c"
		declare -n _invdispcache2="${3}dispcache"
		_invdispcache[$2]= _invdispcache2[$4]=
		invcswtmp="${_invc[$2]}" invswtmp="${_inv[$2]}"
		_invc[$2]="${_invc2[$4]}" _inv[$2]="${_inv2[$4]}"
		_invc2[$4]="$invcswtmp" _inv2[$4]="$invswtmp"
	}
	# DescribeItem <Type> <Num> <Tags>
	#  output the item describtion
	function DescribeItem {
		[ "$2" -gt 1 ] && echo -n "$2 * "
		dscItem="${1:-NDC}"
		[ "$1" == ' ' ] && dscItem='VSP'
		PrintChar "$dscItem" "$3" "$defaultstyle"
	}
	# RemoveCache <Container> <Slot>
	function RemoveCache {
		declare -n _invdispcache="${1}dispcache"
		_invdispcache[$2]=''
	}
	# ShowInventory <Container> [warp:9] [from:0] [to:<container.size>]
	#  show every item in the [ from, to ) of the target container
	function ShowInventory {
		declare -n _inv="$1"
		declare -n _invc="${1}c"
		declare -n _invsize="${1}size"
		declare -n _invdispcache="${1}dispcache"
		local warp="${2:-9}"
		local msgs=() width=() lens=() i=
		for((i=0;i<warp;++i));do
			width[i]=7
		done
		local sel="${5:-$selhotbar}" lsel="${6:-$sel}"
		[ "$sel" != "$lsel" ] && {
			_invdispcache[sel]='' _invdispcache[lsel]=''
		}
		local i= from="${3:-0}" to="${4:-$_invsize}"
		for((i=from;i<to;++i));do
			local idxf=$((i-from))
			[ "${_invdispcache[i]}" == '' ] && {
				{ # Just DescribeItem but it's so slow to call the func
					local sinvtgitem="$(
						dscItem="${_inv[i]:-NDC}" dscCnt="${_invc[i]}"  dscTag=` [ "$sel" == "$i" ] && { echo -n E;true; } || echo -n e ` dscLength=0
						[ "$dscCnt" -lt 1 ] && {
							PrintChar "$dscItem" "$dscTag" "$defaultstyle"
							echo -n 'Nothing'
							((dscLength+=7))
							true
						} || {
							[ "$dscCnt" -gt 1 ] && {
						       		echo -n "$dscCnt * "
								((dscLength+=${#dscCnt}+3))
							}
							[ "$dscItem" == ' ' ] && dscItem='VSP'
							PrintChar "$dscItem" "$dscTag" "$defaultstyle"
							((++dscLength))
						}
						echo -n ';'"$dscLength"
					)"
				}
				_invdispcache[i]="$sinvtgitem"
			}
			local len="${_invdispcache[i]##*;}"
			local inwarpp=$((idxf%warp))
			[ "$len" -gt "${width[inwarpp]}" ] && {
				width[inwarpp]=$len
			}
			msgs[idxf]="${_invdispcache[i]%;*}"
			lens[idxf]=$len
		done
		local i= j=
		for((i=from;i<to;++i));do
			[ "$(((i-from)%warp))" == 0 ] && ((i!=from)) && echo
			local inwarpp=$(((i-from)%warp)) idxf=$((i-from))
			echo -n "${msgs[idxf]}"$'\e[0m'
			for((j=width[inwarpp];j>=lens[idxf];--j));do echo -n ' ';done
		done
	}

	# Player Inventory
	PLAYERINV_SIZE=46
	PLAYERINV_CURSOR=45
	PLAYERINV_HOTBAR=9
	PLAYERINV_INVSIZE=45
}
