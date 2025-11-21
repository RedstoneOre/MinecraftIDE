#! /bin/bash
[ -v MCEDITOR_INC_arguments ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Argument parsing loaded'
	MCEDITOR_INC_arguments=
	. "$dirp"/base/check.sh
	unset ArgResult
	# ReadArgument <args>...
	#  return map ArgResult as the parse result
	#  return false if the argument is illegal, set ArgResult[err] as the error message
	function CheckShortOption {
		[ "$1" != generic ] && {
			ArgResult['err']='Multiple sub-args-required options in one short option: '"$2"
			return 1
		}
		return 0
	}
	function ArgConnect {
		local i=
		for i;do echo -n "$i ";done
	}
	function ReadArguments {
		local stat=generic statp= dims=() autodims=()
		declare -gA 'ArgResult=()'
		ArgResult['task']=main
		ArgResult['page']=
		ArgResult['lang']='en-US'
		local ERR_UNSAFE='Unsafe option with --- prefix, if you want to use it, add --unsafe-args, use at your own risk.'
		local i=
		for i; do
			local stop=0
			while [ "$stop" != 1 ];do
				stop=1
				case "$stat" in
					generic)
						[ "${i:0:1}" == '-' ] && { # new option
							[ "${i:1:1}" == '-' ] && { # is long option
								case "$i" in
									--overworld)
										stat=dim statp='mcide:overworld' ;;
									--dim|--dimension)
										stat=dim_id statp=;;
									--open-file|--dim-append)
										stat=dim statp= ;;
									--menu)
										ArgResult['page']=menu ;;
									--open-world|--load-world)
										ArgResult['page']=load_world
										stat=set_world_name statp=
										;;
									--dir)
										stat=set_editor_dir statp=;;
									--world-name)
										stat=set_world_name statp=;;
									--no-simple-mode-prompt)
										ArgResult[no simple mode prompt]=awa;;
									--help)
										ArgResult['task']=help;;
									--rt|--recover-terminal)
										ArgResult['task']=recoverTerminal;;
									--language|--lang)
										stat=lang statp=;;
									--show-log-on-exit)
										ArgResult['show log on exit']=;;
									--vision-size)
										stat=set_vision_size statp=;;
									--vision-size-x)
										stat=set_vision_size statp=x;;
									--vision-size-y)
										stat=set_vision_size statp=y;;
									--unsafe-args)
										ArgResult['unsafe args']=allowed;;
									--safe-args)
										unset ArgResult['unsafe args'];;
									---page)
										[ "${ArgResult['unsafe args']}" ] && {
											stat=set_page
											true
										} || {
											ArgResult['err']="$ERR_UNSAFE"
											return 1
										};;
									---argresult)
										[ "${ArgResult['unsafe args']}" ] && {
											stat=set_argresult statp=
											true
										} || {
											ArgResult['err']="$ERR_UNSAFE"
											return 1
										};;
									---define-dim)
										[ "${ArgResult['unsafe args']}" ] && {
											stat=define_dim statp=
											true
										} || {
											ArgResult['err']="$ERR_UNSAFE"
											return 1
										};;
									*)
										ArgResult['err']='Illegal option: '"$i"
										return 1 ;;
								esac
								true
							} || { # is short option
								local aval=mwodhl
								[[ "${i:1}" =~ [^mwodhlnxy] ]] && {
									ArgResult['err']='Illegal option: '"-${i//[-mwodhlnxy]/} in $i"
									return 1
								}
								[[ "$i" =~ m ]] &&
									ArgResult['page']=menu
								[[ "$i" =~ w ]] && {
									CheckShortOption "$stat" "$i" w || return 1
									ArgResult['page']=load_world
									stat=set_world_name statp=
								}
								[[ "$i" =~ o ]] && {
									CheckShortOption "$stat" "$i" o || return 1
									stat=dim statp='mcide:overworld'
								}
								[[ "$i" =~ d ]] && {
									CheckShortOption "$stat" "$i" d || return 1
									stat=set_editor_dir statp=
								}
								[[ "$i" =~ h ]] && {
									ArgResult['task']=help
								}
								[[ "$i" =~ l ]] && {
									CheckShortOption "$stat" "$i" l || return 1
									stat=lang statp=
								}
								[[ "$i" =~ n ]] && {
									CheckShortOption "$stat" "$i" n || return 1
									stat=set_world_name statp=
								}
								[[ "$i" =~ x ]] && {
									CheckShortOption "$stat" "$i" x || return 1
									stat=set_vision_size statp=x
								}
								[[ "$i" =~ y ]] && {
									CheckShortOption "$stat" "$i" y || return 1
									stat=set_vision_size statp=y
								}
							}
							true
						} || { # new string argument
							stat=dim statp= stop=0
						} ;;
					dim)	# read a dim
						[ -z "$statp" ] && { # not specific dim
							autodims[${#autodims[@]}]="$i"
							true
						} || { # specific dim
							[ -v ArgResult["dim$statp"] ] || dims["${#dims[@]}"]="$statp"
							ArgResult["dim$statp"]="$i"
						}
						stat=generic statp= ;;
					dim_id)
						IsIdName "$i" && {
							stat=dim statp="$i"
							true
						} || {
							ArgResult[err]='Illegal dimension id: '"$i"
							return 1
						} ;;
					set_editor_dir)
						ArgResult['dir']="$i"
						stat=generic statp= ;;
					set_world_name)
						IsFileName "$i" || {
							ArgResult[err]='Illegal world name(must be a file name): '"$i"
							return 1
						}
						ArgResult['world name']="$i"
						stat=generic statp=
						;;
					set_page)
						ArgResult['page']="$i"
						stat=generic statp= ;;
					set_argresult)
						ArgResult['page']="$i"
						[ "$statp" ] && {
							ArgResult["$statp"]="$i"
							stat=generic statp=
							true
						} || {
							statp="$i"
						};;
					set_vision_size)
						IsNumber "$i" && {
							case "$statp" in
								x) ArgResult[vis width]="$i"
									stat=generic statp=;;
								y) ArgResult[vis height]="$i"
									stat=generic statp=;;
								'') ArgResult[vis width]="$i"
									stat=set_vision_size statp=y;;
							esac
							true
						} || {
							ArgResult[err]="Vision size $statp requires a number instead of $i"
							return 1
						}
						;;
					define_dim)
						dims[${#dims[@]}]="$i"
						stat=generic statp=;;
					lang)
						ArgResult['lang']="$i"
						stat=generic statp= ;;
				esac
			done
		done
		local dimcnt=0 dimname=
		for i in "${autodims[@]}";do
			while true;do
				dimname='mcide:custom/'"$((dimcnt-2))"
				[ $dimcnt -eq 0 ] && dimname='mcide:overworld'
				[ $dimcnt -eq 1 ] && dimname='mcide:the_nether'
				[ $dimcnt -eq 2 ] && dimname='mcide:the_end'
				((++dimcnt))
				[ -v ArgResult["dim$dimname"] ] && continue
				ArgResult["dim$dimname"]="$i"
				dims["${#dims[@]}"]="$dimname"
				break
			done
		done
		ArgResult["alldims"]=`ArgConnect "${dims[@]}"`
		[ "${ArgResult[task]}" == main ] && {
			[ -z "${ArgResult[page]}" ] &&{
				ArgResult[page]=create_world
				[ -z "${ArgResult[alldims]}" ] && ArgResult[page]=menu
			}
		}
		[ "$stat" != generic ] && {
			ArgResult['err']="$stat"' sub-args required: '"$i"
			return 1
		}
		return 0
	}
}
