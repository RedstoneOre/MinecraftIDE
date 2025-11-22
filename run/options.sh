#! /bin/bash
[ -v MCEDITOR_INC_options ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'options loaded'
	MCEDITOR_INC_options=
	. "$dirp"/base/check.sh
	. "$dirp"/input/read.sh

	# TextProvider Presets
	function TextProvider_fixed {
		echo -n "$1"
	}
	function TextProvider_danger {
		[ "$3" == focus ] && echo -n $'\e[101m'
		echo -n "$1"
		[ "$3" == focus ] && echo -n $'\e[0m'
	}
	function TextProvider_choice {
		echo -n "$1$2"
	}
	function TextProvider_input {
		echo -n $'\e[1m'"$1"$'\e[0m'"$2"
	}

	# init_option_list <name>
	#  Initialize an option list
	function init_option_list {
		local d=$1
		unset "${d}_text" "${d}_textp" "${d}_pos" "${d}_type" "${d}_stat" "${d}_data" "$d"
		declare -g -A "${d}_text=()"
		declare -g -A "${d}_textp=()"
		declare -g -A "${d}_pos=()"
		declare -g -A "${d}_type=()"
		declare -g -A "${d}_stat=()"
		declare -g -A "${d}_data=()"
		declare -g -A "$d=()"
	}

	# free_option_list <name>
	# Free an option list
	function free_option_list {
		local d=$1
		unset "${d}_text" "${d}_textp" "${d}_pos" "${d}_type" "${d}_stat" "${d}_data" "$d"
	}

	# add_option <listname> <id> [textprovider:fixed] <text> [pos:(current, req see /print/window.sh:16 )] [type:button]
	function add_option {
		local d=$1 id=$2 textp=${3:-fixed} text=$4 pos=$5 type=${6:-button}
		[ "$pos" ] || {
			getCursorPos
			pos="$curY;$curX"
		}
		declare -n "_o_text=${d}_text"
		declare -n "_o_textp=${d}_textp"
		declare -n "_o_pos=${d}_pos"
		declare -n "_o_type=${d}_type"
		declare -n "_o_stat=${d}_stat"
		declare -n "_o_data=${d}_data"
		IsIdName "$id" || return 1
		[ -v _o_type["$id"] ] && return 2
		_o_text["$id"]="$text"
		_o_textp["$id"]="$textp"
		_o_pos["$id"]="$pos"
		_o_type["$id"]="$type"
		_o_stat["$id"]=default
		_o_data["$id"]=
	}
	# update_option <listname> <id>
	function update_option {
		local d=$1 id=$2
		declare -n "_o_text=${d}_text"
		declare -n "_o_textp=${d}_textp"
		declare -n "_o_pos=${d}_pos"
		declare -n "_o_type=${d}_type"
		declare -n "_o_stat=${d}_stat"
		declare -n "_o_data=${d}_data"
		local text="`"TextProvider_${_o_textp["$id"]}" "${_o_text["$id"]}" "${_o_data["$id"]}" "${_o_stat["$id"]}"`"
		echo -n $'\e['"${_o_pos["$id"]}H"
		case "${_o_stat["$id"]}" in
			default)
				echo -n "$text" ;;
			focus)
				echo -n $'\e[7m'"$text"$'\e[0m' ;;
			highlighted)
				echo -n $'\e[106;30m'"$text"$'\e[0m' ;;
		esac
	}
	# show_all_options <listname>
	function show_all_options {
		local d=$1
		declare -n "_o_type=${d}_type"
		local i=
		for i in "${!_o_type[@]}"; do
			update_option "$d" "$i"
		done	
	}
	# change_option_focus <listname> <id>
	function change_option_focus {
		local d=$1 id=$2
		declare -n "_o=$d"
		declare -n "_o_stat=${d}_stat"
		local lfocus="${_o[focus]}"
		[ -n "$lfocus" ] && {
			_o_stat["$lfocus"]=default
			update_option "$d" "$lfocus"
		}
		_o[focus]="$id"
		local tfocus="$id"
		[ -n "$tfocus" ] && {
			_o_stat["$tfocus"]=focus
			update_option "$d" "$tfocus"
		}
	}
	# change_option_focus <listname> <id> <0|1>
	function set_option_highlight {
		local d=$1 id=$2 thl=$3
		declare -n "_o=$d"
		declare -n "_o_stat=${d}_stat"
		[ "$thl" == 0 ] && {
			[ "${_o_stat["$id"]}" == highlighted ] && {
				_o_stat["$id"]=default
				update_option "$d" "$id"
				return 0
			}
			true
		} || {
			[ "${_o_stat["$id"]}" == default ] && {
				_o_stat["$id"]=highlighted
				update_option "$d" "$id"
				return 0
			}
		}
		return 1
	}
	# edit_input_option <listname> <id> <autocomplete_provider>
	function edit_input_option {
		local d=$1 id=$2 provider="$3"
		declare -n "_o_pos=${d}_pos"
		declare -n "_o_data=${d}_data"
		declare -n "_o_text=${d}_text"
		echo -n $'\e['"${_o_pos["$id"]}H"$'\e[1;33m'"${_o_text["$id"]}"$'\e[0m'
		Read_Read "$provider" "${_o_data["$id"]}"
		_o_data["$id"]="$Read_Result"
		update_option "$d" "$id"
	}
	#get_input_value <listname> <id>
	function get_input_value {
		local d=$1 id=$2
		declare -n "_o_data=${d}_data"
		echo -n "${_o_data["$id"]}"
	}
}
