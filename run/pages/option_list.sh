#! /bin/bash
[ -v MCEDITOR_INC_pages_option_list ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Option list loaded'
	MCEDITOR_INC_pages_option_list=
	. "$dirp"/options.sh
	init_option_list clioptl
	add_option clioptl trushed_paths fixed 'Trushed Paths...' '2;4' button
	add_option clioptl marketplace danger 'Visit Offical Minecraft Bedrock Editon Marketplace Pass Introduction Page Via Your System Default Browser According to Xdg-open' '4;4' button

	cliopts=( leave_world_behavior quit_server_behavior trushed_paths  trushed_paths )
	clioptsz="${#cliopts[@]}"
	function option_list_main {
		echo -n $'\ec'
		show_all_options clioptl
		read
	}
}
