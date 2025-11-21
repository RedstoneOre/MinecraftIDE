#! /bin/bash
[ -v MCEDITOR_INC_editor ] || {
	MCEDITOR_INC_editor=
	# dirp as the .../run/ path required
	. "$dirp"/arguments.sh
	. "$dirp"/world.sh
	. "$dirp"/menu.sh
	. "$dirp"/world_list.sh
	. "$dirp"/create_world.sh
	. "$dirp"/option_list.sh
	function editorrecover {
		echo -n $'\e[0m'
		[ "$MCEDITOR_dbgl" -ge 1 ] && echo 'Main Thread Ended'
		echo -n $'\e[?25h'
		stty "$ltty"
	}
	function editormain {
		end=0
		IFS=''
		trap '' SIGINT
		ReadArguments "$@" || {
			echo "${ArgResult[err]}"
			editorrecover
			return 1
		}
		[ "${ArgResult[dir]}" ] &&
			dirgame="${ArgResult['dir']%/}" # remove trailing /
		case "${ArgResult[task]}" in
			main)
				ltty=`stty -g`
				stty -echo icanon
				lang="${ArgResult[lang]}"

				echo -n $'\e[0m\e[?25l'
				[ "$MCEDITOR_dbgl" -gt 1 ] && {
					set | grep -w '^ArgResult'
				}
				unset showlogonexit
				[ -v ArgResult['show log on exit'] ]; showlogonexit=$[1-$?]
				editorpage="${ArgResult[page]}"
				[ "$MCEDITOR_dbgl" -ge 1 ] && echo "Start page: $editorpage"
				while :;do
					_editorpage="$editorpage"
					editorpage=menu
					end=0
					case "$_editorpage" in
						menu)
							menumain;;
						create_world)
							local worldname="${ArgResult['world name']}"
							worldmain "$worldname" create ;;
						create_world.ui)
							CreateWorldScreen ;;
						load_world)
							local worldname="${ArgResult['world name']}"
							worldmain "$worldname" ;;
						world_list)
							worldlistmain ;;
						options)
							option_list_main;;
						exit)
							break;;
					esac
				done
				editorrecover
				[ "$showlogonexit" == 1 ] && vim "$logfile" ;;
			help)
				lang="${ArgResult[lang]}"
				echo -e "`< "$dirassets"/mcide/help/"$lang".txt`" ;;
			recoverTerminal)
				stty echo -icanon
				echo -n $'\e[?25h' ;;
		esac
	}
}
