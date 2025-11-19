#! /bin/bash
[ -v MCEDITOR_INC_print_print_thread ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Printing threads loaded'
	MCEDITOR_INC_print_print_thread=
	. "$dirp"/print.sh
	. "$dirp"/fifo.sh
	function PrintThread {
		echo "a render thread started" >&2
		local cmd=
		IFS=
		while read -N 1 <&17;do
			read -rd $'\n' cmd <&15
			echo -n C >&18
			# echo "Render command recd: $cmd">&2
			{
				local op=
				read -N 1 op
				case "$op" in
					Q) break;;
					T)
						local lnid= cotent= i=
						read -rd ' ' lnid
						IFS=' '
						read -rd $'\n' -a content
						IFS=
						local lstyle="$defaultstyle"
						{
							echo -n R"$lnid"' '
							for i in "${content[@]}";do
								PrintChar "${i#*;}" "${i%%;*}" "$lstyle"
								lstyle="$PrintCharStyle";
							done
							echo
						} >&16
						# echo "Sent render result of $lnid" >&2
						;;
					*);;
				esac
			} < <(echo "$cmd")
		done
		echo "a render thread ended" >&2
	}
}
