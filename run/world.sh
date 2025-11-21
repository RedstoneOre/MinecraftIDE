#! /bin/bash
[ -v MCEDITOR_INC_world ] || {
	MCEDITOR_INC_world=
	# dirp as the .../run/ path required
	. "$dirp"/arguments.sh
	. "$dirp"/input.sh
	. "$dirp"/map.sh
	. "$dirp"/block/proportions.sh
	. "$dirp"/print.sh
	. "$dirp"/print/progress.sh
	. "$dirp"/print/print_thread.sh
	. "$dirp"/block.sh
	. "$dirp"/entity.sh
	. "$dirp"/container.sh
	. "$dirp"/file.sh
	. "$dirp"/save.sh
	. "$dirp"/dimension.sh
	. "$dirp"/fifo.sh
	. "$dirp"/base/check.sh
	. "$dirp"/operate.sh
	# worldmain <worldname> [create|simple|load]
	function resetworlddata {
		for i in "${num2dim[@]}";do
			DeleteDimension "$i"
		done
		ResetScreenShow
		ScheduleScreenUpdate 0
	}
	function worldmain {
		# Special Chars
		#  PLY - Coder
		#  BOL - Begin of Line
		#  OOT - Out of Text(border)
		#  SOT - Start of Tab
		#  POT - Part of Tab
		#  EOT - End of Tab
		#  SCT - Single char Tab
		#  DIG - Focus char
		#  ESP - Espace the following 1 char
		#  ELB - Brack espace left brack
		#  ERB - Brack espace right brack
		#  NDC - No displaying char, only for formattinng
		#  VSP - Visible Space
		unset showlogonexit
		[ -v ArgResult['show log on exit'] ]; showlogonexit=$[1-$?]

		local worldname=$1
		local createmode=${2:-load}
		local worlddir="$dirgame/saves/$worldname"
		[ "$createmode" == create ] && [ "$worldname" == '' ] && {
			createmode=simple
		}
		[ "$createmode" == simple ] && [ -z "${ArgResult[no simple mode prompt]}" ] && {
			echo $'\e[31mWARN: You are now in simple mode, it means ur world will be lost after u exit the editor.\e[0m'
			echo $'\e[31mTo prevent this, use -n|--world-name <name> option to set the world name\e[0m'
			echo $'\e[31mIf you want to ignore this prompt, add --no-simple-mode-prompt\e[0m'
			echo $'\e[31mIf you want to continue, press Enter\e[0m'
			echo $'\e[31mIf you want to leave, press any other key\e[0m'
			local op=
			read -N 1 op
			[ "$op" != $'\n' ] && {
				editorpage=exit
				return 1
			}
		}
		[ "$createmode" == create ] && [ -e "$worlddir" ] && {
			echo $'\e[31mWARN: You are trying to override an existed world.\e[0m'
			echo $'\e[31mTo open the world, use `-w|--open-world|--load-world <name>`\e[0m'
			echo $'\e[31mTo override the world, delete the original one manually.\e[0m'
			read -N 1
			editorpage=exit
			return 1
		}
		[ "$end" == 1 ] && {
			return 1
		}
		[ "$MCEDITOR_dbgl" -ge 1 ] && {
			echo "World name: $worldname"
			echo "World dir: $worlddir"
			echo "Create mode: $createmode"
		}
		[ "$createmode" == load ] && {
			[ ! -d "$worlddir" ] && {
				echo 'World does not exist'
				sleep 1
				return 1
			}
			[ ! -f "$worlddir"/level.json ] && {
				echo 'World is invalid (level.json not found)'
				sleep 1
				return 1
			}
		}
		[ "$createmode" != load ] && {
			eval local dims=(${ArgResult['alldims']})
			local efile=
			for i in "${dims[@]}";do
				efile="${ArgResult["dim$i"]}"
				NewDimension "$i" "$efile"
				local did=`GetDimensionID "$i"`
				local filesize=`wc -m "$efile" | { read -d ' ' -r l;echo -n $l ; }`
				Read_File "$did" "$filesize" <"$efile" 6> >(ShowProgressBar "Reading $i from $efile[" ']' 50)
				[ "$MCEDITOR_dbgl" -gt 1 ] && {
					echo "Load dimension: $i(ID: $did) from $efile"
					heap_print "fcm$did"
				}
			done
			[ "$MCEDITOR_dbgl" -gt 1 ] && {
				set | grep -Ew '^(num2dim|dim2num)'
				echo "Target Dimension: $dim"
				read
			}
			InvInit inv 46
			InvInit craft2 5
			px=0 py=0
			true
		} || {
			load_save "$worlddir" || {
				echo 'Error loading world' >&2
				return 1
			}
			local i=
			echo 'This save could modify these files:'
			for i in "${dim2num[@]}";do
				[ "$i" ] || continue
				local tdimfile="${dimfile[$i]}" 
				[ -f "$tdimfile" ] && {
					tdimfhash="`sha1sum -- "$tdimfile"`"
					tdimfhash="${tdimfhash/ */}"
					[ "$tdimfhash" == "${dimfhash[i]}" ] &&
						echo $'\t'"$tdimfile" || {
							echo $'\t\e[31m(MODIFIED AFTER LAST SAVE)'"$tdimfile"$'\e[0m'
							echo $'\t\t\e[31mHash of the currect file: '"$tdimfhash"$'\e[0m'
							echo $'\t\t\e[31mHash when save:           '"${dimfhash[i]}"$'\e[0m'
						}
					true
				} || {
					echo $'\t\e[34m(CREATE)'"$tdimfile"$'\e[0m'
				}
			done
			echo 'Press Other Keys to Leave'
			echo 'Press Enter to Continue'
			local op=
			read -N 1 op
			[ "$op" != $'\n' ] && {
				resetworlddata
				return 1
			}
		}
		GetDimensionID mcide:overworld >/dev/null || NewDimension mcide:overworld
		dim=`GetDimensionID mcide:overworld`
		[ "$end" == 1 ] && {
			return
		}

		[ "$MCEDITOR_dbgl" -lt 2 ] && {
			echo -n $'\e[0m\e[?25l\ec'
		}
		[ "$MCEDITOR_dbgl" -ge 3 ] && {
			for((i=0;i<lines;++i));do
				echo -n '['"${fc["$rdim.$i.c"]}"']'
				for((j=0;j<${fc["$rdim.$i.c"]};++j));do
					echo -n "${fc["$rdim.$i.$j"]}"'|'
				done
				echo;echo
			done
			read
		}
		vx="${ArgResult[vis width]:-10}" vy="${ArgResult[vis height]:-5}"

		[ "$MCEDITOR_dbgl" -ge 2 ] && {
			CreateEntity $ENTITY_ITEM `GetItemEntityData BOL 5` 1 0 0
			CreateEntity $ENTITY_ITEM `GetItemEntityData BOL 2` 1 1 0
			CreateEntity $ENTITY_ITEM `GetItemEntityData BOL 1` 2 1 0
			CreateEntity $ENTITY_ITEM `GetItemEntityData BOL 63` 2 2 0
		}
		CreateEntity $ENTITY_ITEM `GetItemEntityData 'The Illegal Item' ` -20 -20 0

		local printthreads=4 i=
		for((i=0;i<printthreads;++i));do
			PrintThread &
		done

		local power=100 prignore=0 isdig=0 canceldrop=0 opsuc=0 invopen=0 linvopen=0 linvselected=
		unset invselected; invselected=
		tickc=0
		local lttime="`date +%s%N`" tgnspt=500000000
		{
			while true;do
				local tinvopen=$invopen
				[ "$invopen" == 1 ] && {
					echo -n $'\e[0;0H'
					[ "$end" == 1 ] && break
					[ -z "$invselected" ] && {
						invselected=$selhotbar
						linvselected=$invselected
					}
					ShowInventory craft2 2 0 4
					echo -n $'\e[1;18HCrafting\e[2;18H------->  '
					ShowInventory craft2 1 4 5
					echo
					RemoveCache inv $selhotbar
					ShowInventory inv 9 0 45 $invselected $linvselected
					echo -n $'\nCursor: '
					RemoveCache inv $invselected
					ShowInventory inv 1 45
					echo -n $'\e[K'
					echo
					linvselected=$invselected
					true
				} || {
					echo op >&12
					[ "$end" == 1 ] && break
					echo -n $'\e[0;0H'
					[ "$linvopen" == 1 ] && {
						invselected= linvselected=
						ScheduleScreenUpdate 0
						ResetScreenShow
					}
					PrintCharStyle="$defaultstyle"
					GetScreenLeftUpperCorner "$px" "$py"
					sScrLeft="$ScrLeft" sScrUpper="$ScrUpper"
					local i= j= tasked=()
					echo -n 'C' >&18
					for((i=sScrUpper;i<=py+vy;++i));do
						[ "$UpdScreen" != 1 ] && [ "${UpdScreen[i-(sScrUpper)+1]}" != 1 ] && {
							continue
						}
						local tl=()
						local taskln=$((i-sScrUpper))
						read -rd 'C' <&18
						{
							echo -n "T$taskln"
							for((j=sScrLeft;j<=px+vx;++j));do
								prc=`getChar "$j" "$i"`
								[ "$i" == "$focy" ] && [ "$j" == "$focx" ] && prc=DIG
								[ "$i" == "$py" ] && [ "$j" == "$px" ] && prc=PLY
								[ "$prc" == ' ' ] && prc=SPE
								[ "${entopos["$dim.$j.$i.c"]:-0}" -gt 0 ] && {
									hasentity='E'
									true
								} || hasentity='e'
								echo -n " $hasentity;$prc"
							done
							echo
						} >&15
						# echo "Render command sent: T$taskln ${tl[@]}" >&2
						echo -n ' ' >&17
						tasked[taskln]=1
					done
					read -rd 'C' <&18
					local tres=() tresln=
					while ((${#tasked[@]} > 0));do
						read -r -d $'\n' -t 5 tresln <&16 || {
							echo 'Rendering Timed Out for line(s) '"${!tasked[@]}"
							break
						}
						# echo "Received rendered data: $tresln" >&2
						{
							local tresop= treslc= tresstr=
							read -N 1 tresop
							[ "$tresop" == R ] && {
								read -rd ' ' treslc
								read -rd $'\n' tresstr
							}
						} < <(echo "$tresln")
						# echo "Received rendered $treslc: $tresstr" >&2
						tres[treslc]="$tresstr"
						unset tasked[treslc]
						for i in "${!tres[@]}"; do
							echo -n $'\e['$((i+1))'H'"${tres[i]}"$'\e[0m\e[K'
						done
					done
					echo -n $'\e['"$((vy*2+2))"'H'

					UpdScreen=()
					true
				}
				echo -n "Pos: ($px, $py), Focus: ($focx, $focy), Dim: `GetDimensionName "$dim"`, Tick $tickc"$'\e[K\n'
				[ "$dip" -gt 0 ] && {
					echo -n 'Mining char '"$(PrintChar `getChar "$focx" "$focy"`)"$'\e[0m at ('"$focx"', '"$focy"'), progress '"$dip"'/'"$(getHardness `getChar "$focx" "$focy"`)"$'\e[K\n'
				}
				echo -n 'Power: '"$power"$'\e[K\n'
				prentsz="${entopos["$dim.$px.$py.c"]:-0}"
				[ "$prentsz" -gt 0 ] && {
					echo $'Entities: \e[K'
					for((prenti=0;prenti<prentsz;++prenti));do
						echo -n '  '
						DiscribeEntity "${entopos["$dim.$px.$py.$prenti"]}"
						echo $'\e[0m\e[K'
					done
				}
				ShowInventory inv 9 0 9 '' $lselhotbar ;echo

				echo -n $'\e[K\n\e[K\n\e[K\n'
				[ "${entopos["$dim.$px.$py.c"]:-0}" -gt 0 ] && {
					apickcnt="${entopos["$dim.$px.$py.c"]}" apick=()
					for((i=0;i<apickcnt;++i));do
						apicktt="${entopos["$dim.$px.$py.$i"]}"
						[ "${entities["$apicktt"]}" == $ENTITY_ITEM ] && {
							apick[${#apick[@]}]="$apicktt"
						}
					done
					for i in "${apick[@]}";do
						ParseItemEntityData "${entdatas[$i]}"
						InvPick inv "$entityitemtype" "$entityitemcnt"
						DeleteEntity "$i"
					done
				}
				[ "$tinvopen" != 1 ] && {
					local ntdate="`date +%s%N`"
					((ltdate+=tgnspt, ntdate>ltdate)) && ltdate="$((ntdate+tgnspt))"
					while [ "$ntdate" -lt "$ltdate" ] ;do
						sleep 0.02
						ntdate="`date +%s%N`"
					done
					opsuc=0
					echo opend >&12
					{
						isdig=0 ismove=0
						op=''
						IFS=' '
						#echo 'qwqwqwq'
						read -a op -t 0.2 <&4
						echo "ciallo~It's ${op[@]} meow~"$'\e[K' >&2
						[ "$op" ] && Operate_"${op[@]}"
						IFS=''
						[ "`date +%s%N`" -gt "$ltdate" ] && opsuc=1
					}
					[ "$canceldrop" -gt 0 ] && {
						canceldrop="$[canceldrop-1]"
					} || {
						[ "`getChar "$px" "$[py+1]"`" == ' ' ] && {
							move 0 1
							ismove=1
						}
					}
					power="$[power+1]"
					[ "$isdig" == 0 ] && {
						dip="$[dip-3]"
						[ "$dip" -lt 0 ] && dip=0
						true
					} || {
						[ "$power" -gt 0 ] && power="$[power-1]"
					}
					[ "$ismove" == 1 ] && {
						movefocus "$px" "$py" s
					}
					linvopen="$invopen"
					tickc="$[tickc+1]"
					true
				} || {
					op=''
					IFS=' '
					echo opinv >&12
					read -a op <&4
					IFS=''
					"OperateInv_${op[@]}"
					echo "cinvllo~It's ${op[@]} meow~"$'\e[K' >&2
				}
			done
			echo 'disconnect' >&12
			for((i=0;i<printthreads;++i)); do
				echo 'Q'
				echo -n ' ' >&3
			done >&15 3>&17
		} 4< <(InputThread)
		echo -n $'\ec'
		local i=
		for i in "${num2dim[@]}";do
			local edid=`GetDimensionID "$i"`
			local efile="${dimfile[edid]}"
			[ "$efile" ] || {
				echo 'Ignored to save dim '"$i"' into a file because it do not have a reference'
			       	continue
			}
			{
				echo t'Backing up original file' >&6
				echo p0 >&6
				cp -- "$efile" "$efile".meditor.backup &&
				Save_File `GetDimensionID "$i"` "$efile" > >( {
					fhashdata="`tee "$efile" | sha1sum`"
					echo -n "awa#$fhashdata#"
				} >&14 ) &&
				rm -- "$efile".meditor.backup || {
					echo 'tFAILED TO SAVE' >&6
					echo 'e' >&6
					echo -n "awa#FailedToSave.qwq -#" >&14
				}
				WaitProgressBarEnd
				local hashdata=
				read -rd '#' -u 14
				read -rd '#' -u 14 hashdata
				local hashv="${hashdata/ */}"
				dimfhash[edid]="$hashv"
				echo "Saved dim $i to file $efile(hash $hashv)" >&2
			} 6> >(ShowProgressBar "Saving $i to $efile [" ']' 50 )
		done
		echo 'File saved'
		[ "$createmode" != simple ] && {
			echo '(test) Saving save...'
			save_save "$worlddir" && echo 'Save saved' || echo 'Save save failed'
		}
		echo 'Endding world...'
		resetworlddata
		[ "$MCEDITOR_dbgl" -ge 1 ] && {
			echo 'Waiting...'
		}
		wait
		echo -n $'\e[?25h'
		[ "$createmode" == simple ] && {
			editorpage=exit
			true
		} || {
			echo 'Press any key to continue'
			read -N 1
			read -N 2147483647 -t 0.1
		}
	}
}
