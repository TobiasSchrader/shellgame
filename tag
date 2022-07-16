#!/bin/bash
#
# Author: Tobias Schrader
set -o nounset

source engine.sh

debug=false
prg=$(basename "$0")

while getopts ':d' optname; do
  case $optname in
    d) debug=true;;
    :) echo "$prg: Argument for option $OPTARG is missing" >&2; exit 2;;
    \?) echo "$prg: Unknown option $OPTARG" >&2; exit 2;;
    *) echo "$prg: Internal error, unexpected option $OPTNAME" >&2; exit 3;;
  esac
done
shift $(( $OPTIND - 1 ))

declare -A controls=()
# divide by 4 for y coordinates
controls[w]=-4 # up
controls[s]=4 # down
controls[a]=-1 # right
controls[d]=1 # left
controls[0]=0 # stand

declare -a enemies=()
declare -A xpos=()
declare -A ypos=()
declare -A canMove=(false)

action() {
  [[ $1 == 'q' ]] && end
  playerMove $1
}

playerMove() {
  $canMove || return
  xpos=$(( xpos+(controls[$1]%4) ))
  ypos=$(( ypos+(controls[$1]/4) ))
  canMove=false
}

game_setup() {
  clear_map
  xpos=10
  ypos=10
}

build_map() {
  setpos $xpos $ypos "@"
}

worldtick() {
  ((gametime++))
  lasttick=${EPOCHREALTIME/./}
  for e in "${enemies[@]}"; do
    attack $e
  done
 build_map
 canMove=true
}

engine
