# Author: Tobias Schrader

: ${debug:=false}

declare -i gametime=0
declare -i tickrate=50000
declare -i waittime=$tickrate
declare -i lasttick=${EPOCHREALTIME/[.,]/}
declare -i nexttick=${EPOCHREALTIME/[.,]/}


log() {
  echo $@ >&2
}

tick() {
  worldtick
  draw
  nexttick=$((${EPOCHREALTIME/[.,]/} + $tickrate))
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

setpos() { 
  local xpos=$1
  local ypos=$2
  local symbol=$3
  map[$j + $i * $xsize]=${symbol:1:1}
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

end() {
  tput cnorm
  stty echo
  tput cup $ysize 0
  exit
}

setup() {
  stty -echo
  tput civis
  clear_map
  type game_setup 2> /dev/null && game_setup
  clear
}

engine() {
  setup
  while true; do
  local pretick=${EPOCHREALTIME/[.,]/}
    waittime=$nexttick-${EPOCHREALTIME/[.,]/}
    [[ $waittime -le 0 ]] && tick
      readwait=0.05
  local posttick=${EPOCHREALTIME/[.,]/}
  log $posttick
  log $((posttick - pretick))
    read -s -n 1 -t $readwait input && action "$input"
  done
}

trap 'end' 0
