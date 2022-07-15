# Author: Tobias Schrader

: ${debug:=false}

declare -i gametime=0
declare -i nexttick=${EPOCHREALTIME/[.,]/}
declare -i tickrate=100000
declare -i waittime=$tickrate
home="$(tput home)"

tick() {
  nexttick+=$tickrate
  worldtick
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
  line=''
  p=0
  for ((i=0; i < $ysize; i++ )); do
    for ((j=0; j < $xsize; j++ )); do
      line+="${map[p++]}"
    done
    line+=$'\n'
  done
  echo "$home$line"
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
  game_setup
  clear
}

engine() {
  setup
  while true; do
    waittime=$nexttick-${EPOCHREALTIME/[.,]/}
    TIMEFORMAT=$'tick:\treal\t%3lR\tuser\t%3lU\tsys\t%3lS'
    [[ $waittime -le 0 ]] && time tick
    waittime=$nexttick-${EPOCHREALTIME/[.,]/}
    if [[ $waittime -gt 100 ]]; then
      printf -v readwait '0.%06d' $waittime
    else
      readwait=0.000100
    fi
    TIMEFORMAT=$'action:\treal\t%3lR\tuser\t%3lU\tsys\t%3lS'
    read -n 1 -t $readwait input && time action "$input"
    $debug && echo "readwait=$readwait input=${input@Q}" >&2
  done
}

trap 'end' 0
