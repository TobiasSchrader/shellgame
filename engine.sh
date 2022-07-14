# Author: Tobias Schrader

: ${debug:=false}

declare -i gametime=0
declare -i nexttick=${EPOCHREALTIME/[.,]/}
declare -i tickrate=500000
declare -i waittime=$tickrate

tick() {
  nexttick+=$tickrate
  worldtick
  draw
  waittime=$tickrate
}

declare -a map

: ${xsize:=$(tput cols)}
: ${ysize:=$(tput lines)}

draw() {
  clear
  for ((i=0; i < $ysize; i++ )); do
    for ((j=0; j < $xsize; j++ )); do
      echo -n "${map[ $j + $i * $xsize ]}"
    done
    echo
  done
}

engine() {
  while true; do
    $debug && echo $EPOCHREALTIME $nexttick
    waittime=$nexttick-${EPOCHREALTIME/[.,]/}
    [[ $waittime -le 0 ]] && tick
    waittime=$nexttick-${EPOCHREALTIME/[.,]/}
    if [[ $waittime -gt 0 ]]; then
      printf -v readwait '0.%06d\n' $waittime
    else
      readwait=0
    fi
    $debug && echo $readwait
    read -s -n 1 -t $readwait input && action "$input"
  done
}
