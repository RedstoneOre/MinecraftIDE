#! /bin/bash
[ -v MCEDITOR_INC_file ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'File loading header loaded'
	MCEDITOR_INC_file=
	. "$dirp"/map.sh
	. "$dirp"/espmap.sh
	. "$dirp"/print/progress.sh
	. "$dirp"/heap.sh
	# load_file <Dimension> <FileSize> < (standard input)
	#  Read a file into a dimension
	#  output progress to fd 6
	function load_file {
		echo -n b >&2
		local readfileend=0 filesize="${2:-114514}"
		ldim=$dim
		dim="${1:-0}"
		echo -n c >&2
		heap_init fcm$dim
		echo -n d >&2
		local i= j= progupdcd=5 rchars=0
		echo -n e >&2
		for((i=0;;++i));do
			setChar 0 $i 'BOL'
			for((j=1;;));do
				((--progupdcd, progupdcd<0)) && {
					[ "$end" == 1 ] && return
					[ "$rchars" -gt "$filesize" ] && filesize=$((rchars*2))
					echo p"$((rchars*50/filesize))" >&6
					local progtext="$((rchars*10000/filesize))"
					while [ ${#progtext} -lt 3 ]; do progtext=0$progtext; done
					echo t"${progtext:0:0-2}.${progtext:0-2}% $rchars/$filesize" >&6
					progupdcd=10;
				}
				((++rchars))
				IFS=
				read -r -n 1 -d $'\0' tfc || {
					readfileend=1
					break
				}
				[ "$tfc" == $'\n' ] && break
				mceespace "$tfc"
				for((k=0;k<"${#tfcres[@]}";++k));do
					setChar $j $i "${tfcres[k]}"
					(( ++j ))
				done
			done
			[ "$readfileend" == 1 ] && break
		done
		lines[$dim]="$i"
		dim=$ldim
		echo p50 >&6
		echo tCompleted >&6
		echo 'e\n' >&6
		WaitProgressBarEnd
	}
	function _file_connect_str {
		local i=
		for i;do echo -n "$i"; done
	}
	# Save_File <Dimension> > (output)
	#  Save a dimension to a file
	#  output progress to fd 6
	function save_file {
		local unkespmsg='(What is this f char?)'
		ldim=$dim
		dim="${1:-0}"
		echo t'Preparing data 0%' >&6
		heap_copy fcm$dim fcmsave
		echo p10 >&6
		local charp= char= espst=0 espc=() esps= esprs= started=0
		local csize=`heap_getsize fcmsave`
		local tcsize=$csize progupdcd=0
		while [ "$tcsize" -gt 0 ]; do
			((--progupdcd, progupdcd<0)) && {
				echo p"$((5+(csize-tcsize)*45/csize))" >&6
				local progtext="$(((csize-tcsize)*10000/csize))"
				while [ ${#progtext} -lt 3 ]; do progtext=0$progtext; done
				echo t"Saving ${progtext:0:0-2}.${progtext:0-2}% $((csize-tcsize+1))/$csize" >&6
				progupdcd=10;
			}
			charp=`heap_gettop fcmsave`
			char="`getChar ${charp//.*/} ${charp//*./}`"
			heap_pop fcmsave
			tcsize=`heap_getsize fcmsave`
			case "$espst" in
				0) 
					case "${char:-OOT}" in
						BOL) 
							[ "$started" == 1 ] && echo
							started=1 ;;
						OOT) ;;
						ESP) espst=1 ;;
						ELB) espst=2 ;;
						ERB) ;;
						SOT) espst=3 ;;
						POT) echo -n $'\t' ;;
						EOT) echo -n $'\t' ;;
						*) echo -n "$char" ;;
					esac ;;
				1)
					esprs="${unesp["e$char"]:-"$unkespmsg"}"
					[ "$esprs" == 'NUL' ] && {
						echo -n $'\0'
					} || {
						echo -n "$esprs"
					}
					espst=0 ;;
				2)
					[ "$char" == 'ERB' ] && {
						esps=`_file_connect_str "${espc[@]}"`
						esprs="${unesp["e$esps"]:-"$unkespmsg"}"
						[ "$esprs" == 'NUL' ] && {
							echo -n $'\0'
							true
						} || {
							echo -n "$esprs"
						}
						espst=0 espc=() esps=
						true
					} || {
						espc[${#espc[@]}]="$char"
					} ;;
				3)
					[ "$char" == 'EOT' ] && {
						echo -n $'\t'
						espst=0
					} ;;
			esac
		done
		dim=$ldim
		echo p50 >&6
		echo t'Completed' >&6
		echo 'e\n' >&6
	}
}
