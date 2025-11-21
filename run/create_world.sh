#! /bin/bash
[ -v MCEDITOR_INC_create_world ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Creating world screen loaded'
	MCEDITOR_INC_create_world=
	. "$dirp"/options.sh
	function CreateWorldScreen {
		local COPL=create_pos
		init_option_list $COPL
		add_option $COPL name input '[N] WorldName ' '2;2' input
		show_all_options $COPL
		echo -n $'\e[?25h'
		edit_input_option $COPL name Read_None
		echo -n $'\e[?25l'
		add_option $COPL opt.overworld input '[O] Overworld File ' '4;2' input
		add_option $COPL cancel danger '[Q Enter] Cancel' '10;2' button
		add_option $COPL create fixed '[C Enter] CREATE!' '10;25' button
		show_all_options $COPL
		local op= focus=
		while true;do
			read -N 1 op
			case "$op" in
				[nN]) edit_input_option $COPL name Read_None
					change_option_focus $COPL name;focus=;;

				[qQ]) change_option_focus $COPL cancel;focus=cancel;;

				[oO]) edit_input_option $COPL opt.overworld Read_File
					change_option_focus $COPL opt.overworld;focus=;;

				[cC]) change_option_focus $COPL create;focus=create;;
				$'\n')	case "$focus" in
						cancel) break;;
						create) break;;
					esac;;
			esac
		done
		echo -n $'\ec'
		editorpage=world_list
	}
}
