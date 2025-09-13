#! /bin/bash
[ -v MCEDITOR_INC_world_list ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'World list loaded'
	MCEDITOR_INC_world_list=
	. "$dirp"/options.sh
	function delete_world_with_prompt {
		echo $'\ecAre you sure you want to delete this world?'
		echo "'$1' will be lost forever! (A long time!)"
		echo $'Type `delete WORLDNAME\' to delete it'
		local delcmd=
		stty echo
		read -rei "$1" delcmd 2>&1
		stty -echo
		[ "$delcmd" == "delete $1" ] && {
			rm -rf "$dirgame"/saves/"$1" &&
				echo $'\e[31mWorld is successfully deleted!\e[0m' ||
				echo 'Failed to delete the world!'
			true
		} || {
			echo $'\e[32mCanceled!\e[0m'
		}
		read -N 1
	}
	# worldlistButtonMode <opsel>
	function worldlistButtonMode {
		local opsel="$1"
		change_option_focus worlds "${sops[sopc]}"
		set_option_highlight worlds "$opsel" 1
		while :;do
			change_option_focus worlds "${sops[sopc]}"
			read -r -N 1 op
			case "$op" in
				[aA]) ((sopc=sopc-1<0?sopcnt-1:sopc-1)) ;;
				[dD]) ((sopc=sopc+1>=sopcnt?0:sopc+1)) ;;
				[qQ])
					doquit=1
					break;;
				$'\t')
					((sopc=sopc+1>=sopcnt?0:sopc+1))
					[ "$sopc" == 0 ] && break ;;
				$'\e')
					read -r -N 1 -t 0.1 op
					case "$op" in
						'[')
							read -r -N 1 -t 0.1 op
							case "$op" in
								D) ((sopc=sopc-1<0?sopcnt-1:sopc-1)) ;;
								C) ((sopc=sopc+1>=sopcnt?0:sopc+1)) ;;
								Z)
									((sopc=sopc-1<0?sopcnt-1:sopc-1))
									((sopc==sopcnt-1)) && break ;;
							esac ;;
					esac ;;
				$'\n')
					case "${sops[sopc]}" in
						join)
							doquit=2 editorpage=load_world
							ArgResult['world name']="${optionsel[opsel]}"
							break;;
						create)
							echo -n 'awa';;
						delete)
							delete_world_with_prompt "${optionsel[opsel]}"
							doquit=2 editorpage=world_list
							break;;
						back)
							doquit=1
							break;;
					esac;;
			esac
		done
	}
	function worldlistmain {
		echo $'\e'"[3;6H"'Minecraft IDE -- Worlds'
		init_option_list worlds
		local optionsel=()
		for i in "$dirgame"/saves/*; do
			[ -d "$i" ] && add_option worlds "${#optionsel[@]}" fixed "${i##*/}" "$((5+${#optionsel[@]}))" button
			optionsel[${#optionsel[@]}]="${i##*/}"
		done
		add_option worlds join fixed 'Join' "$((6+${#optionsel[@]}))" button
		add_option worlds create fixed 'Create' "$((6+${#optionsel[@]}));10" button
		add_option worlds delete danger 'Delete' "$((6+${#optionsel[@]}));20" button
		add_option worlds back fixed 'Back' "$((6+${#optionsel[@]}));30" button

		show_all_options worlds
		opcnt=${#optionsel[@]}
		local op= opsel=0
		local sops=( join create delete back ) sopc=0 sopcnt=4 doquit=0
		while :;do
			[ "$doquit" -gt 0 ] && {
				[ "$doquit" == 1 ] && editorpage=menu
				break
			}
			change_option_focus worlds "$opsel"
			read -r -N 1 op
			case "$op" in
				[qQ]) doquit=1;;
				[wW]) ((opsel=opsel-1<0?opcnt-1:opsel-1)) ;;
				[sS]) ((opsel=opsel+1>=opcnt?0:opsel+1)) ;;
				$'\t') worldlistButtonMode $opsel ;;
				$'\e')
					read -r -N 1 -t 0.1 op
					case "$op" in
						'[')
							read -r -N 1 -t 0.1 op
							case "$op" in
								A) ((opsel=opsel-1<0?opcnt-1:opsel-1)) ;;
								B) ((opsel=opsel+1>=opcnt?0:opsel+1)) ;;
								Z) worldlistButtonMode $opsel;;
							esac ;;
					esac ;;
				$'\n') 
					editorpage=load_world
					ArgResult['world name']="${optionsel[opsel]}"
					break;;
			esac
		done
		echo -n $'\ec'
	}
}
