
#! /bin/bash
[ -v MCEDITOR_INC_fifo ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Fifos loaded'
	MCEDITOR_INC_fifo=
	unset tmpfifo
	tmpfifo="$dirtmp"/$$.fifo
	# newfifo <id>
	function newfifo {
		mkfifo "$tmpfifo"
		eval exec "$1<>" '"$tmpfifo"'
		rm "$tmpfifo"
	}
	newfifo 11	# block/progress	ProgressBar
	newfifo 12	# input			InputThread
	# newfifo 13	# input			MixedStdin
	newfifo 14	# world			sha1sum
	newfifo 15	# print			PrintTaskSend
	newfifo 16	# print			PrintTaskResult
	newfifo 17	# print			PrintTaskSend2
	newfifo 18	# print			PrintTaskResult2
	exec 30<&0		# -			FixedStdin
	exec 31>&1		# -			FixedStdout
	exec 32>&2		# -			FixedStderr
}
