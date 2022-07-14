# Author: Tobias Schrader

: ${debug:=false}

declare -i gametime=0
declare -i nexttick=${EPOCHREALTIME/[.,]/}
declare -i tickrate=100000
declare -i waittime=$tickrate

tick() {
  nexttick+=$tickrate
  worldtick
  draw
  waittime=$tickrate
}

declare -a map

: ${xsize:=$(tput cols)}
: ${ysize:=$(($(tput lines) - 1))}

clear_map() {
  for ((i=0; i < $ysize; i++ )); do
    for ((j=0; j < $xsize; j++ )); do
      map[$j + $i * $xsize]=' '
    done
  done
}


draw() {
  tput home
  for ((i=0; i < $ysize; i++ )); do
    line=''
    for ((j=0; j < $xsize; j++ )); do
      line+="${map[ $j + $i * $xsize ]}"
    done
    echo "$line"
  done
}

close() {
  tput cnorm
  stty echo
  clear
  exit
}

setup() {
  stty -echo
  tput civis
  clear_map
  clear
}

engine() {
  setup
  while true; do
    waittime=$nexttick-${EPOCHREALTIME/[.,]/}
    [[ $waittime -le 0 ]] && tick
    waittime=$nexttick-${EPOCHREALTIME/[.,]/}
    if [[ $waittime -gt 0 ]]; then
      printf -v readwait '0.%06d\n' $waittime
    else
      readwait=0
    fi
    read -s -n 1 -t $readwait input && action "$input"
  done
}
