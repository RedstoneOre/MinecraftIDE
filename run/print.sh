#! /bin/bash
[ -v MCEDITOR_INC_print ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Printing header loaded'
	MCEDITOR_INC_print=
	defaultstyle='9.-'
	unset CharStyle CharPrc
	declare -A CharStyle CharPrc
	CharStyle['PLY']='4'
	CharPrc['PLY']='@'
	CharStyle['BOL']='2'
	CharPrc['BOL']='|'
	CharStyle['OOT']='3'
	CharPrc['OOT']='#'
	CharStyle['SOT']='2'
	CharPrc['SOT']='['
	CharStyle['POT']='2'
	CharPrc['POT']='.'
	CharStyle['EOT']='2'
	CharPrc['EOT']=']'
	CharStyle['DIG']='4'
	CharPrc['DIG']='#'
	CharStyle['ESP']='2'
	CharPrc['ESP']='^'
	CharStyle['ELB']='2'
	CharPrc['ELB']='<'
	CharStyle['ERB']='2'
	CharPrc['ERB']='>'
	CharStyle['VSP']='4'
	CharPrc['VSP']='␣'
	CharStyle['SPE']='0'
	CharPrc['SPE']=' '
	CharStyle['NDC']='9'
	CharPrc['NDC']=''
	CharStyle['default']='9'

	# PrintChar <Code> <Tags> <LastCharStyle>
	#  set PrintCharStyle as the char's style
	function PrintChar {
		charbg='-'
		[[ "$2" =~ E ]] && {
			charbg=7
		}
		charstyle="${CharStyle[$1]:-${CharStyle[default]}}"
		[ "$charstyle.$charbg" == '9.7' ] && charstyle=0
		PrintCharStyle="$charstyle.$charbg"
		stylestr='' stylereset=0
		[ "${3//*./}" != "$charbg" ] && {
			[ "$charbg" == '-' ] && {
				stylestr="$stylestr"'0;'
				stylerreset=1
				true
			} || stylestr="$stylestr"'10'"$charbg"';'
		}
		{ [ "$stylerreset" == 1 ] || [ "${3//.*/}" != "$charstyle" ]; } && {
			stylestr="${stylestr}3$charstyle"';'
		}
		[ "${#stylestr}" -gt 1 ] && echo -n $'\e['"${stylestr:0:-1}m"
		echo -n "${CharPrc["$1"]-"$1"}"
	}
	function PrintIgnore {
		case "$1" in
			0) ;;
			1) echo -n $'\e[C';;
			*) echo -n $'\e['"$1"'C';;
		esac
	}
	declare -A screen
	function SetScreenShow {
		[ "${screen["$1.$2"]}" != "$3" ] && {
			screen["$1.$2"]="$3"
			return 0
		}
		return 1
	}
	function ResetScreenShow {
		screen=()
	}
	UpdScreen=(1)
	# GetScreenLeftUpperCorner <px> <py>
	#  Get the posion of left upper corner on the map
	#  Set ScrLeft as the x and ScrUpper as the y
	function GetScreenLeftUpperCorner {
		((ScrLeft=px-vx))
		((ScrUpper=py-vy))
	}
	# ScheduleScreenUpdate <scry>
	function ScheduleScreenUpdate {
		[ "$1" -ge 0 ] && [ "$1" -le "$[vy*2+1]" ] && UpdScreen[$1]=1
	}
}
