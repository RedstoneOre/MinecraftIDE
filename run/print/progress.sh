#! /bin/bash
[ -v MCEDITOR_INC_print_progress ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Progress bar header loaded'
	MCEDITOR_INC_print_progress=
	. "$dirp"/fifo.sh
	function ShowProgressBar {
		trap '' SIGINT
		local prefix="${1:-[}" surfix="${2:-]}" length="${3:-10}" chars="${4:-.#}" op=
		local st="${#prefix}"
		echo -n "$prefix"
		for((i=0;i<length;++i));do
			echo -n "${chars:0:1}"
		done
		echo -n "$surfix"
		local stpos="${#prefix}" numpos=-1 numlen=0 tgprog=0
		while read -r op;do
			local opn="${op:1}"
			case "${op:0:1}" in
				t)
					local lnumpos=$numpos lnumlen=$numlen
					(( numlen=${#op}, numpos=stpos+(length/2)-(numlen/2)+1 ))
					local i=
					[ $lnumpos -gt -1 ] && {
						echo -n $'\e['$lnumpos'G'
						for((i=lnumpos;i<numpos;++i));do
							(( i-stpos<=tgprog )) && {
								echo -n "${chars:1}"
								true
							} || echo -n "${chars:0:1}"
						done
						echo -n $'\e['$((numpos+numlen-1))'G'
						for((i=numpos+numlen-1;i<lnumpos+lnumlen-1;++i));do
							(( i-stpos<=tgprog )) && {
								echo -n "${chars:1}"
								true
							} || echo -n "${chars:0:1}"
						done
					}
					echo -n $'\e['$numpos'G'"$opn";;
				p)
					local i=
					[ $tgprog -lt $opn ] && {
						for((i=tgprog+1;i<=opn;++i));do
							(( stpos+i < numpos || stpos+i >= numpos+numlen-1 )) &&
								echo -n $'\e['$((stpos+i))'G'"${chars:1}"
						done
						true
					} || {
						for((i=opn+1;i<=tgprog;++i));do
							(( stpos+i < numpos || stpos+i >= numpos+numlen-1 )) &&
								echo -n $'\e['$((stpos+i))'G'"${chars:0:1}"
						done
					}
					tgprog=$opn;;
				e)
					echo -ne "$opn"
					break;;
			esac
		done
		echo >&11
		#echo -n $'\e[G\e[K'
	}
	function WaitProgressBarEnd {
		read -r -N 1 -u 11
	}
}
