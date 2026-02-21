#! /bin/bash
[ -v MCEDITOR_INC_heap ] || {
	[ "$MCEDITOR_dbgl" -ge 2 ] && echo 'Heap header loaded'
  MCEDITOR_INC_heap=
  pos_cmp() {
    local v1=$1 v2=$2

    local n1="${v1//.*/}"
    local n2="${v2//.*/}"
    local m1="${v1//*./}"
    local m2="${v2//*./}"

    n1=${n1:-0}
    n2=${n2:-0}

    if (( m1 < m2 )); then
      return 0
    elif (( m1 > m2 )); then
      return 2
    elif (( n1 < n2 )); then
      return 0
    elif (( n1 > n2 )); then
      return 2
    else
      return 1
    fi
  }

  # heap_init <name>
  #  initialize a new heap
  heap_init() {
    local h=$1
    unset "$h" "${h}_size" "${h}_idx"
    declare -g -a "${h}=()"
    declare -g "${h}_size=0"
    declare -g -A "${h}_idx=()"
  }

  # heap_delete <name>
  #  delete a heap
  heap_delete() {
    local h=$1
    unset "$h" "${h}_size" "${h}_idx"
  }

  _swap() {
    local h=$1 i=$2 j=$3
    declare -n _heap="$h"
    declare -n _heap_idx="${h}_idx"
    local tmp=${_heap[i]}
    _heap[i]=${_heap[j]}
    _heap[j]=$tmp
    _heap_idx[${_heap[i]}]=$i
    _heap_idx[${_heap[j]}]=$j
  }

  _heapify_up() {
    local h=$1 idx=$2
    declare -n _heap="$h" _sz="${h}_size"
    while (( idx>0 )); do
      local parent=$(((idx-1)/2))
      pos_cmp "${_heap[idx]}" "${_heap[parent]}"
      if (( $? == 0 )); then
        _swap "$h" "$idx" "$parent"
        idx=$parent
      else
        break
      fi
    done
  }

  _heapify_down() {
    local h=$1 idx=$2
    declare -n _heap="$h" _sz="${h}_size"
    local left right smallest
    while :; do
      left=$((2*idx+1))
      right=$((2*idx+2))
      smallest=$idx

      if (( left < _sz )); then
        pos_cmp "${_heap[left]}" "${_heap[smallest]}"
        (( $? == 0 )) && smallest=$left
      fi

      if (( right < _sz )); then
        pos_cmp "${_heap[right]}" "${_heap[smallest]}"
        (( $? == 0 )) && smallest=$right
      fi

      if (( smallest != idx )); then
        _swap "$h" "$idx" "$smallest"
        idx=$smallest
      else
        break
      fi
    done
  }

  # heap_init <name> <value>
  #  insert a new value into the heap
  #  return failure if the version already exists
  heap_insert() {
    local h=$1 v=$2
    # echo "Insert $v to $h" >> _heap.log
    [ -z "$h" ] && return 1
    [ -z "$v" ] && return 1
    declare -n _heap="$h"
    declare -n _heap_idx="${h}_idx"
    [ -v _heap_idx[$v] ] && return 1
    local -n _sz="${h}_size"
    _heap[_sz]="$v"
    _heap_idx[$v]="$_sz"
    ((_sz++))
    _heapify_up "$h" $(( _sz-1 ))
    return 0
  }

  # heap_pop <name>
  #  output the popped value unless the heap is empty
  #  return failure if the heap is empty
  heap_pop() {
    local h=$1
    declare -n _heap="$h"
    declare -n _heap_idx="${h}_idx"
    local -n _sz="${h}_size"
    if (( _sz==0 )); then
      return 1
    fi
    local out=${_heap[0]}
    # echo "Pop $out from $h" >> _heap.log
    unset _heap_idx[$out]
    [ "$_sz" -gt 1 ] && {
        _heap[0]=${_heap[_sz-1]}
        unset '_heap[_sz-1]'
        _heap_idx[${_heap[0]}]=0
        ((_sz--))
        _heapify_down "$h" 0
	true
    } || {
        unset _heap[0]
        _sz=0
    }
    return 0
  }

  # heap_gettop <name>
  #  output the top value of the heap unless the heap is empty
  #  return failure if the heap is empty
  heap_gettop() {
    local h=$1
    declare -n _heap="$h"
    local -n _sz="${h}_size"
    if (( _sz==0 )); then
      return 1
    fi
    echo -n "${_heap[0]}"
    return 0
  }

  # heap_delete_idx <name>
  #  delete by index
  heap_delete_idx() {
    local h=$1 idx=$2
    declare -n _heap="$h"
    declare -n _heap_idx="${h}_idx"
    local -n _sz="${h}_size"
    if (( idx<0 || idx>=_sz )); then
      return 1
    fi
    unset _heap_idx[${_heap[idx]}]
    # echo "Remove ${_heap[idx]} from $h" >> _heap.log
    _heap[idx]=${_heap[_sz-1]}
    _heap_idx[${_heap[idx]}]=$idx
    unset '_heap[_sz-1]'
    ((_sz--))
    _heapify_down "$h" "$idx"
    _heapify_up   "$h" "$idx"
    return 0
  }

  # heap_delete_idx <name>
  #  delete by value
  heap_delete_val() {
    local h=$1 idx=$2
    declare -n _heap="$h"
    declare -n _heap_idx="${h}_idx"
    [  -v _heap_idx[$idx] ] || return 1
    heap_delete_idx $h "${_heap_idx[$idx]}"
    return $?
  }

  # heap_print <name>
  #  print the heap
  heap_print() {
    local h=$1
    declare -n _heap="$h"
    declare -n _heap_idx="${h}_idx"
    local -n _sz="${h}_size"
    echo "$h (size=$_sz): [${_heap[@]}]"
    local i;
    for i in "${!_heap_idx[@]}";do
      echo -n "$i: ${_heap_idx[$i]}, "
    done
    echo
  }
}

# heap_copy <source> <destination>
#  copy the heap from source to destination
heap_copy() {
  local src=$1 dst=$2
  declare -n _src="$src"
  declare -n _src_size="${src}_size"
  declare -n _src_idx="${src}_idx"
  heap_init "$dst"
  declare -n _dst="$dst"
  declare -n _dst_size="${dst}_size"
  declare -n _dst_idx="${dst}_idx"
  local i=
  for i in "${!_src[@]}";do
	  _dst["$i"]="${_src["$i"]}"
  done
  _dst_size=$_src_size
  for i in "${!_src_idx[@]}";do
	  _dst_idx["$i"]="${_src_idx["$i"]}"
  done
}

# heap_getsize <name>
#  get the size of the heap
heap_getsize() {
  local h=$1
  declare -n _sz="${h}_size"
  echo -n "$_sz"
}
