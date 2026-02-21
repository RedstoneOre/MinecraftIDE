#! /bin/bash
[ -v MCEDITOR_INC_editor ] || {
	MCEDITOR_INC_editor=
	# dirp as the .../run/ path required
	. "$dirp"/arguments.sh
	. "$dirp"/optional_features.sh
	. "$dirp"/pages/world.sh
	. "$dirp"/pages/menu.sh
	. "$dirp"/pages/world_list.sh
	. "$dirp"/pages/create_world.sh
	. "$dirp"/pages/option_list.sh
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
				create_feature_list mcide
				[ "${ArgResult['sounds']}" != no ] && which mpv nc >/dev/null 2>&1 && enable_feature mcide bgm 1
				[ "$MCEDITOR_dbgl" -gt 1 ] && {
					set | grep -w '^ArgResult'
				}
				unset showlogonexit
				[ -v ArgResult['show log on exit'] ]; showlogonexit=$[1-$?]
				editorpage="${ArgResult[page]}"
				local mpvIpcServer= mpvPid=
				check_feature mcide bgm 1 && {
					mpvIpcServer='@mpv-ipc-'$$
					mpv --no-video --force-window=no --idle=no --input-terminal=no --quiet --input-ipc-server="$mpvIpcServer" "$dirassets"/mcide/sounds/bgm/1.mp3 --loop >&2 & mpvPid="$!"
				}
				[ "$MCEDITOR_dbgl" -ge 1 ] && echo "Start page: $editorpage"
				while :;do
					local _editorpage="$editorpage"
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
						minecraft)
							xdg-open https://www.minecraft.net/marketplace/marketplace-pass
							echo 'Enjoy Minecraft Marketplace content :)'
							read -N 1
							break;;
						exit)
							break;;
					esac
				done
				editorrecover
				check_feature mcide bgm 1 && {
					echo '{"command":["quit"]}' | {
						nc -U "$mpvIpcServer" >&2 || {
							kill -0 "$mpvPid" &&
							kill -s SIGINT "$mpvPid"
						}
					}
				}
				[ "$showlogonexit" == 1 ] && vim "$logfile"
				true;;
			help)
				lang="${ArgResult[lang]}"
				echo -e "`< "$dirassets"/mcide/help/"$lang".txt`" ;;
			recoverTerminal)
				stty echo -icanon
				echo -n $'\e[?25h' ;;
		esac
	}
}
