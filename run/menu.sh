#! /bin/bash
[ -v MCEDITOR_INC_menu ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Menu loaded'
	MCEDITOR_INC_menu=
	. "$dirp"/print/window.sh
	. "$dirp"/options.sh
	function menumain {
		getWindowSize
		local iconsize=20
		[ "$((winX/6))" -gt "$winY" ] && {
			iconsize=$winY
			true
		} || {
			iconsize=$((winX/6))
		}
		[ "$iconsize" -lt 1 ] && iconsize=1
		case "$TERM" in
			xterm-color|*-256color)
				local icon="`"$dirlib"/ascii-image-converter/ascii-image-converter -C -H $iconsize "$dirassets"/mcide/MinecraftIDE.png`" ;;
			*)
				local icon="`"$dirlib"/ascii-image-converter/ascii-image-converter -H $iconsize "$dirassets"/mcide/MinecraftIDE.png`" ;;
		esac
		local stline=$(((winY-iconsize)/2))
		echo -n $'\ec\e'"[${stline}H$icon"
		echo $'\e'"[$((stline+3));$((iconsize*2+6))H"'Minecraft IDE'
		echo $'\e'"[$((stline+4));$((iconsize*2+10))H"$'-- A simple and \e[9mannoy\e[0;4minterest\e[0ming editor'
		init_option_list menu
		echo -n $'\e'"[$((stline+6));$((iconsize*2+6))H"
		add_option menu worlds fixed 'Singleplayer' '' button
		echo -n $'\e'"[$((stline+8));$((iconsize*2+6))H"
		add_option menu servers fixed 'Multiplayer' '' button
		echo -n $'\e'"[$((stline+10));$((iconsize*2+6))H"
		add_option menu options fixed 'Options...' '' button
		echo -n $'\e'"[$((stline+12));$((iconsize*2+6))H"
		add_option menu leave fixed 'Quit Editor' '' button
		show_all_options menu
		while :;do
			local op= opsel=0
			local optionsel=( worlds servers leave ) opcnt=3
			while :;do
				change_option_focus menu "${optionsel[opsel]}"
				read -r -N 1 op
				case "$op" in
					[qQ]) opsel=2; break;;
					[wW]) ((opsel=opsel-1<0?opcnt-1:opsel-1)) ;;
					[sS]) ((opsel=opsel+1>=opcnt?0:opsel+1)) ;;
					$'\e')
						read -r -N 1 -t 0.1 op
						case "$op" in
							'[')
								read -r -N 1 -t 0.1 op
								case "$op" in
									A) ((opsel=opsel-1<0?opcnt-1:opsel-1)) ;;
									B) ((opsel=opsel+1>=opcnt?0:opsel+1)) ;;
								esac ;;
						esac ;;
					$'\n') break;;
				esac
			done
			case "${optionsel[opsel]}" in
				worlds)
					editorpage=world_list
					break;;
				leave)
					editorpage=exit
					break;;
				options)
					editorpage=options
					break;;
				*) echo "${optionsel[opsel]}";;
			esac
		done
		echo -n $'\ec'
	}
}
