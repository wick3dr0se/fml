#!/usr/bin/env bash
# shellcheck disable=SC2015,SC2172,SC2207
# SC2207 -- Prefer mapfile or read -a to spli... breaks reverse
# SC2172 -- Trapping signals by number is not... trap -l is ez
# SC2015 -- Note that A && B || C is not if-t... duh

set -eEuo pipefail ignoreeof

stty -echoctl

LC_ALL=C
LANG=C

init_term()
{
shopt -s checkwinsize; (:;:)&& ((rows=LINES-1))

printf '\e[?1049h\e[2J\e[?7l\e[?25l\e[1;%dr\e[%dH' "$LINES" "$rows"
}

end(){ printf '\e[?1049l\e[2J\e[?7h\e[?25h'&& exit; }

reset_term(){ printf '\e[2J\e[%dH\e[?7l\e[?25l' "$rows"; }

reverse(){
local -n foo="$1"

shopt -s extdebug
bar()( printf '%s\n' "${BASH_ARGV[@]}" )
foo=($(bar "${foo[@]}"))&& unset "foo[-1]"
shopt -u extdebug
}

read_keys()
{
read -rsn1; [[ $REPLY == $'\e' ]]&& read -rsn2
key="${REPLY^^}"
}

prompt(){ printf '\e[H\e[2K\e[?7h\e[?25h%b ' "$1"; }

hidden_toggle()
{
[[ $(shopt -p dotglob) =~ -u ]]&&
  shopt -s dotglob|| shopt -u dotglob
get_files
}

change_dir()
{
if [[ ${marked-} == \* ]]; then
  cd -- -|| return
  unset status mark marked
else
  cd -- "${1:-$marked}"|| return
fi; get_files
}

file_open()
{
bar='[←]back [→]open [↑]exec'
printf '\e[?1049l\e[2J\e[E\e[?7l'

mapfile -tn 250 <"$marked"&& printf '%s\n' "${MAPFILE[@]}"
status='viewing'; hud
}

file_close()
{
status='marked'
init_term&& draw_files; hud
}

file_exec()
{
reset_term&& bash "$marked"
status='executed'; hud
}

make_file()
{
prompt 'New file name:'
read -re
if :>"$REPLY"; then
  mark="9m$REPLY" status='created'
  get_files
else
  status='error' mark="9m$REPLY exist"
  hud
fi
}

make_dir()
{
prompt 'New directory name:'
read -re
if mkdir "$REPLY"; then
  status='created' mark="4m$REPLY\e[m/"
  get_files
else
  status='error' mark="4m$REPLY\e[m/ exist"
  hud
fi
}

file_del()
{
prompt "Do you want to delete \e[3$mark\e[m? [y/n]:"
read -rsn1
if [[ ${REPLY,,} == y ]]; then
  del="$path/$marked"
  rm -fr "${del-}"&& status='deleted'
  [[ $marked == "${PWD##*/}" ]]&& change_dir ../|| get_files
else
  printf '\e[2K'
fi
}

comm_exec()
{
prompt ':'
read -re
reset_term
if bash -c "$REPLY"; then
  status='executed'
else
  prompt 'Command not found'
  status='error'
fi
mark="3m$REPLY" bar='[←]back'; hud
}

get_files()
{
unset files

IFS=$'\n'
[[ $PWD == / ]] && PWD=
for fp in "$PWD"/*; do
  file="${fp##*/}"

  if [[ -h $fp ]]; then
    [[ $TERM =~ 256 ]]&& color='8;5;42'|| color='6;1'
    file+='\e[m@'
  elif [[ -d $fp ]]; then
    [[ $TERM =~ 256 ]]&& color='8;5;147'|| color='4;1'
    file+='\e[m/'
  elif [[ -x $fp|| $fp == *'.sh' ]]; then
    [[ $TERM =~ 256 ]]&& color='8;5;210'|| color='2;1'
    file+='\e[m*'
  else
    [[ $TERM =~ 256 ]]&& color='8;5;248'|| color='7;2'
  fi

  files+=("${color}m$file")
done
reverse files
filesTwo=("${files[@]}") fileCount="${#filesTwo[@]}"

draw_files&& cursor="$rows"
}

draw_files()
{
unset hist; i=0&& reset_term
printf '\e[3%b\e[m\n' "$rows" "${files[@]}"
bar='[←]back [→]open [q]uit'; hud
}

cursor()
{
(( fileCount > rows ))&&{
  if (( ${#files[@]} > rows&& cursor < 1 )); then
    cursor="$rows"
    files=("${files[@]:0:${#files[@]}-$rows}")
    draw_files
  elif (( cursor > rows )); then
    cursor=1
    files=("${filesTwo[@]:0:${#files[@]}+$rows}")
    draw_files
  fi
  (( rows-cursor == ${#files[@]} ))&& cursor="$rows"
}||{
  ((cursorMin=LINES-fileCount))
  if (( cursor > rows )); then
    cursor="$cursorMin"
  elif (( cursor < cursorMin )); then
    cursor="$rows"
  fi
}
hover="${files[$cursor-$LINES]}"
printf '\e[%dH\e[4%b\e[m' "$cursor" "$hover"

(( fileCount == 1 ))||{
  hist+=("${cursor}H\e[3${hover}")
  (( i ))&&{
    printf '\e[%b\e[m' "${hist[0]}"
    hist=("${hist[@]:1}")
  }|| i=1
}
}

hud()
{
printf '\e[%dH\e[44mfml\e[m%s\e[3%b\e[m %s' "$LINES" \
  "${status:+ ${status^} : }" "${mark:-  }" "$bar"
}

keymap()
{
read_keys
case $key in
  :) comm_exec
    for((;;)){
      read_keys
      case $key in
        :) comm_exec;;
        H|\[D) draw_files&& break;;
      esac
    }
  ;;
  A) hidden_toggle;;
  D) make_dir;;
  F) make_file;;
  X|\[3) [[ $marked ]]&& file_del;;
  H|\[D) change_dir ../;;
  J|\[B) ((cursor++));;
  K|\[A) ((cursor--));;
  L|\[C|'') status='marked' mark="$hover" path="$PWD"
    marked="${mark#[0-9]*m}" marked="${marked%\\e[m?}"

    change_dir||{
      file_open

      for((;;)){
        read_keys
        case $key in
          H|\[D) draw_files&& break;;
          K|\[A) file_exec|| return;;
          L|\[C|'') "${VISUAL:-${EDITOR:-vi}}" "$marked";;
        esac
      }
      file_close
    }
  ;;
  Q) end;;
esac
}

trap end 2
trap 'init_term&& get_files' 28

init_term&& get_files
for((;;)){ cursor; keymap; }
