#!/usr/bin/env bash

export LC_ALL=C

IFS='[;' read -sp $'\e[9999;9999H\e[6n' -d R -rs _ LINES _
((rows=LINES-1))

clear(){ printf '\e[2J\e[%dH' "$rows"; }

printf '\e[?1049h\e[?7l\e[?25l'

end(){ printf '\e[?1049l\e[?7h\e[?25h'&& exit; }

reverse()
{
local -n foo="$1"

shopt -s extdebug

bar()( printf '%s\n' "${BASH_ARGV[@]}" )
foo=($(bar "${foo[@]}"))
unset foo[-1]

shopt -u extdebug
}

draw_files(){ printf '\e[3%b\e[m\n' "${files[@]}" ;}

hud()
{
printf '\e[%dH\e[2K\e[44mfm\e[m%s\e[3%b\e[m %s' \
  "$LINES" "${status:+ | ${status^}: }" \
  "${mark:+$mark |}" '[←]back [→]open [q]uit'
}

term(){ [[ $TERM =~ 256 ]]&& :; }

get_files()
{
clear
unset files
IFS=$'\n'
for fp in "$PWD"/*; do
  file="${fp##*/}"

  if [[ -h $fp ]]; then
    file+='\e[m@'
    term&& color='8;5;42'|| color='6;1'
  elif [[ -f $fp&& -x $fp|| $fp == *'.sh' ]]; then
    file+='\e[m*'
    term&& color='8;5;210'|| color='2;1'
  elif [[ -d $fp ]]; then
    file+='\e[m/'
    term&& color='8;5;147'|| color='4;1'
  else
    term&& color='8;5;248'|| color='7;2'
  fi

  files+=("${color}m$file")
done

reverse files
filesOG=("${files[@]}") fileCount="${#files[@]}"

draw_files
hud
}

hover()
{
printf '\e[%dH\e[4%b\e[m' "$cursor" "${files[$cursor-$LINES]}"

hist+=("$cursor"); (( cursor == hist ))||
  printf '\e[%dH\e[3%b\e[m' "$hist" "${files[$hist-$LINES]}"

(( i ))&& hist=("${hist[@]:1}")|| i=1
}

scroll()
{
(( fileCount > rows ))&&{
  if (( cursor < 1 )); then
    files=("${files[@]:0:${#files[@]}-$rows}")
    cursor="$rows"&& draw_files
  elif (( cursor > rows )); then
    files=("${filesOG[@]:0:${#files[@]}+$rows}")
    cursor=1&& draw_files
  fi
  hud
}||{
  ((cursorMin=LINES-${#files[@]}))
  if (( cursor > rows )); then
    cursor="$cursorMin"
  elif (( cursor < cursorMin )); then
    cursor="$rows"
  fi
}
}

read_keys()
{
read -rsn1 key
[[ $key == $'\e' ]]&& read -rsn2 key
key="${key^^}"
}

change_dir()
{
cd "${1:-$marked}"&&{
  get_files
  cursor="$rows"
}|| return
}

mapkeys()
{
read_keys
case $key in
  Q) end;;
  D) printf '\e[H\e[2K%s' 'New directory name: '
    
    read -r
    mkdir "$REPLY"&&{
      status='created' mark="4m$REPLY\e[m/"
      get_files
    }||{
      status='error' mark="4m$REPLY\e[m/ exist"
      hud
    }
  ;;
  F) printf '\e[H\e[2K%s' 'New file name: '
    
    read -r
    >"$REPLY"&&{
      mark="9m$REPLY" status='created'
      get_files
    }||{
      status='error' mark="9m$REPLY exist"
      hud
    }
  ;;
  H|\[D) change_dir ../;;
  J|\[B) ((cursor++));;
  K|\[A) ((cursor--));;
  L|''|\[C) status='marked' path="$PWD"
    mark="${files[$cursor-$LINES]}"
    marked="${mark#[0-9]*m}" marked="${marked%\\e[m?}"
    
    change_dir||{
      printf '\e[?1049l'
      clear&& cat "$marked"
      status='viewing'; hud
      
      for((;;)){
        read_keys
        case $key in
          Q) end;;
          H|\[D) status='marked'&& get_files&& break;;
          L|\[C) "${EDITOR:-${VISUAL:-vi}}" "$marked";;
        esac
      }
    }

    printf '\e[?1049h\e[?25l'
    clear&& draw_files; hud
  ;;
  X|\[3) [[ $marked ]]&&{
    printf '\e[H\e[2K%b' \
      "Do you want to delete \e[3$mark\e[m? [y/n]: "

    read -rsn1
    [[ ${REPLY,,} == 'y' ]]&&{
      rm -fr "$path/$marked"&& status='deleted'
      
      [[ $marked == ${PWD##*/} ]]&&
        change_dir ../|| get_files
    }|| printf '\e[2K'
  }
  ;;
esac
}

get_files
for((;;)){
  hover 2>/dev/null

  mapkeys

  scroll
}
