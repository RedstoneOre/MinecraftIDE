#! /bin/bash

# This is a header for reading input
# You can use it in your object but
#	The author won't take responsibility for BUGs.
# To Use This,please set tty -echo before


[ -v MCEDITOR_INC_input_read ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Autocomplete Reading loaded'
	MCEDITOR_INC_input_read=
	function Read_SpRead {
		#Read with special IFS
		Read_IFSb="$IFS"
		IFS="$1"
		Read_SpRead_Args=()
		for Read_SpRead_i;do
			Read_SpRead_Args[${#Read_SpRead_Args[@]}]="$Read_SpRead_i"
		done
		Read_SpRead_Args[0]='read'
		"${Read_SpRead_Args[@]}"
		IFS="$Read_IFSb"
	}

	# Get Curser Pos
	function Read_GetPos {
		[ "$Read_DoOpNinp" == 1 ] &&
		while read -t 0.01 -N 1 Read_OpNinp;do 
			[ "$Read_OpNinp" == '' ] || {
				# echo -n '[get'"$Read_OpNinp"']'
				Read_OpGot[${#Read_OpGot[@]}]="$Read_OpNinp"
				false
			} &&
				break
		done
		echo -n '[6n'
		read -d '['
		read -d 'R' Read_GetPos
		Read_SpRead ';' -r Read_Posy Read_Posx < <(echo -n "$Read_GetPos")
		Read_Pos='['"$Read_GetPos"'H'
	}

	#Insert
	function Read_GetCharExplain {
		Read_PrintWhite=0;
		case "$1" in
			'') Read_Print='[\e]' ;;
			'') Read_Print='[C-s]' ;;
			'') Read_Print='[C-q]' ;;
			'') Read_Print='[C-c]' ;;
			'') Read_Print='[C-v]' ;;
			'') Read_Print='[C-x]' ;;
			'') Read_Print='[C-z]' ;;
			'') Read_Print='[C-a]' ;;
			'') Read_Print='[\b]' ;;
			'') Read_Print='[C-w]' ;;
			'') Read_Print='[C-o]' ;;
			'	')
				Read_GetPos
				[ "$[Read_Posx%8]" -eq 0 ] && {
					Read_Print='_'
					true
				} || Read_Print=$'{\t\e[D}' ;;
			$'\n') Read_Print='[Enter]' ;;
			[0-9a-zA-Z~!@#$%^\&*\(\)_+\`\-=\[\]\\{}\|\;\':\",./\<\>\?\ ]) Read_Print="$1";Read_PrintWhite=1 ;;
			NONE)Read_PrintWhite=1;Read_Print='';;
			*) Read_Print="[$(echo -n "$1" | od -A n -t x1)]";;
		esac
		[ "$Read_PrintWhite" != 1 ] && echo -n '[31m'
		echo -n "$Read_Print"
		[ "$Read_PrintWhite" != 1 ] && echo -n '[0m'
	}
	function Read_PrintBack {
		for((Read_PrintBackI = $[Read_BackPos-1];Read_PrintBackI>=0;--Read_PrintBackI));do
			Read_GetCharExplain "${Read_Back[Read_PrintBackI]}"
		done
	}
	function Read_ConnectBack {
		for((Read_PrintBackI = $[Read_BackPos-1];Read_PrintBackI>=0;--Read_PrintBackI));do
			echo -n "${Read_Back[Read_PrintBackI]}"
		done
	}
	function Read_Ins {
		Read_Line[Read_InsPos]="$1"
		Read_InsPos="$[Read_InsPos+1]"
		Read_GetCharExplain "$1"
		{
			Read_GetPos
			Read_PrSize[Read_InsPos]="$Read_Pos"
		}
		[ "$2" == C ] && echo -n $'\e[K'
		Read_PrintBack
		echo -n "${Read_PrSize[Read_InsPos]}"
	}
	#Remove
	function Read_Remove {
		[ "$Read_InsPos" -gt 0 ] && {
			Read_InsPos="$[Read_InsPos-1]"
			echo -n "${Read_PrSize[Read_InsPos]}"
			[ "$1" != s ] && echo -n '[K'
			Read_PrintBack
			echo -n "${Read_PrSize[Read_InsPos]}"
		}
	}
	#Connect
	function Read_Connect {
		Read_Sz=-100
		for Read_Connecti;do
			[ "$Read_Sz" -le -100 ] && {
				Read_Sz="$Read_Connecti"
				continue
			}
			[ "$Read_Sz" -le 0 ] && break
			echo -n "$Read_Connecti"
			Read_Sz="$[Read_Sz-1]"
		done
	}

	#Read Autocomplete
	# Read Files
	function Read_File {
		Read_Fileg=( "$1"* )
		Read_AcReq=()
		Read_FileSz="${#1}"
		for Read_Filei in "${Read_Fileg[@]}";do
			[ "$Read_Filei" != "$1"'*' ] &&
				Read_AcReq[${#Read_AcReq[@]}]="${Read_Filei:$Read_FileSz}"
		done
		# Read_AcReq[${#Read_AcReq[@]}]=''
	}
	#None
	function Read_None {
		return
	}
	function Read_Autocomplete {
		Read_GetPos
		Read_ComPos="$Read_Pos"
		"$1" "$2"
		Read_ComSz="${#Read_AcReq[@]}"
		[ "$Read_ComSz" -lt 1 ] && return
		Read_requireKey=''
		Read_requireKeyFound=0
		Read_requireKeyReqT=-1
		Read_IndexAddVal=1
		while true;do
			[ "$Read_requireKeyFound" == 2 ] && {
				Read_ComRes="$Read_requireKey"
				Read_requireKey=''
				return
			}
			for ((Read_Comi=0;Read_Comi<Read_ComSz && Read_Comi>=0;Read_Comi+=Read_IndexAddVal)) do
				Read_IndexAddVal=1
				Read_ComVal="${Read_AcReq[Read_Comi]}"

				# echo "$Read_RequireKey"':' "$Read_Comi" '==' "$Read_requireKeyReqT" '?'
				[ "$Read_Comi" == "$Read_requireKeyReqT" ] && {
					Read_requireKeyReqT=-1
					Read_requireKeyFound=1
					Read_requireKey=''
					true
				} || {
					[ "$Read_requireKey" != '' ] && {
						[ "${Read_ComVal:0:1}" == "$Read_requireKey" ] || {
							continue
						}
					}
				}

				echo -n '[33m'"$Read_ComVal"' [AutoComplete][0m[K'"$Read_Pos"
				read -rN 1 Read_ComOp
				case "$Read_ComOp" in
					'	') Read_IndexAddVal=1; continue ;;
					'') break ;;
					'') read -t 0.01 -N 1 Read_ComOp2 && {
							case "$Read_ComOp2" in
								\[)	read -t 0.01 -N 1 Read_ComOp3
									case "$Read_ComOp3" in
										Z) Read_IndexAddVal=-1;;
									esac;;
							esac
							true
						} || {
							echo -n '[K'
							Read_ComRes=''
							return
						};;
					'')
						echo -n '^[[K'
						Read_ComRes=''
						return;;
					$'\n')
						Read_ComRes="$Read_ComVal"
						return ;;
					*) Read_requireKey="$Read_ComOp";Read_requireKeyReqT="$Read_Comi" ;;
				esac
			done
		done
	}

	#Read Main
	# Read_Read <autocomplete_provider> [initial_text]
	function Read_Read {
		Read_InsMode=0
		Read_GetPos
		Read_Line=() Read_PrSize=( "$Read_Pos" ) Read_InsPos=0
		Read_Back=() Read_PrSize_Back=() Read_BackPos=0
		Read_OpGot=() Read_OpCur=0
		[ "$2" ] && {
			for((i=0;i<${#2};++i));do
				Read_Ins "${2:$i:1}"
			done
		}
		while true;do
			[ "${#Read_OpGot[@]}" -gt "$Read_OpCur" ] && {
				Read_DoOpNinp=0
				# echo -n '[33m[MemOpGet'"${#Read_OpGot[@]} $Read_OpCur $Read_Op"'][0m'
				Read_Op="${Read_OpGot[Read_OpCur]}"
				Read_OpCur="$[Read_OpCur+1]"
				[ "${#Read_OpGot[@]}" -le "$Read_OpCur" ] && {
					Read_OpGot=() Read_OpCur=0
				}
				true
			} || {
				Read_DoOpNinp=1
				read -N 1 Read_Op
			}
			[ "$Read_InsMode" == 1 ] && {
				Read_Ins "$Read_Op"
				while true;do
					Read_Op=''
					read -N 1 -t 0.01 Read_Op
					[ "${#Read_Op}" -gt 0 ] || break
					Read_Ins "$Read_Op"
				done
				Read_InsMode=0
			} || {
				case "$Read_Op" in
					[0-9a-zA-Z~!@#$%^\&*\(\)_+\`\-=\[\]\\{}\|\;\':\",./\<\>\?\ \~\`]) Read_Ins "$Read_Op" ;;
					'') read -N 1 -t 0.01 Read_Op &&
						case "$Read_Op" in
							\[) read -N 1 -t 0.01 Read_Op &&
								case "$Read_Op" in
									2) read -N 1 -t 0.01 Read_Op &&
										case "$Read_Op" in
											\~) Read_InsMode=1;;
										esac;;
									3) read -N 1 -t 0.01 Read_Op &&
										case "$Read_Op" in
											\~)
												Read_BackPos="$[Read_BackPos-1]"
												#Read_Ins 'NONE' C
												echo -n "${Read_PrSize[Read_InsPos]}"
												Read_PrintBack
												echo -n $'\e[K'"${Read_PrSize[Read_InsPos]}";;
										esac;;
									C)
										[ "$Read_BackPos" -gt 0 ] && {
											Read_BackPos="$[Read_BackPos-1]"
											Read_Ins "${Read_Back[Read_BackPos]}" "${Read_PrSize_Back[Read_BackPos]}"
										};;
									D)
										[ "$Read_InsPos" -gt 0 ] && {
											Read_Back[Read_BackPos]="${Read_Line[Read_InsPos-1]}"
											Read_PrSize_Back[Read_BackPos]="${Read_PrSize[Read_InsPos-1]}"
											Read_BackPos="$[Read_BackPos+1]"
											Read_Remove s
										};;
								esac;;
						esac;;
					'') Read_Remove;;
					'	') Read_Autocomplete "$1" "$(Read_Connect "$Read_InsPos" "${Read_Line[@]}")"
						Read_DoOpNinp=0
						Read_ComSz="${#Read_ComRes}"
						for((Read_ComGeti=0;Read_ComGeti<Read_ComSz;++Read_ComGeti));do
							Read_Ins "${Read_ComRes:$Read_ComGeti:1}" "$([ "$[Read_ComGeti+1]" -eq "$[Read_ComSz]" ] && echo -n 'C')"
						done
						[ "$Read_ComSz" -le 0 ] && {
							Read_PrintBack
							echo -n "${Read_PrSize[Read_InsPos]}"
						};;
					$'\n') Read_Result="$(Read_Connect "$Read_InsPos" "${Read_Line[@]}")`Read_ConnectBack`";break ;;
				esac
			}
		done
	}
	false && {
		trap '' SIGINT
		stty -echo
		Read_Read Read_File
		e="$Read_Result"
		echo -n "  Res:$e"
		stty echo
	}

	#Ignore
	function Read_Ignore {
		read -N 99999 -t 0.001
	}
}
