#!/bin/bash

# terminal window cells
term_size(){ read -r LINES COLUMNS < <(stty size) ;}; term_size

# trap window resize
trap 'term_size' SIGWINCH

# save cursor position 7 -
# save screen ?47h
# hide cursor ?25l -
# set alternative screen buffer ?1049h -
# disable line wrapping ?7l
printf '\e7\e[?25l\e[?1049h'

# wipe terminal screen
clear(){ printf '\e[2J' ;}

# restore cursor position 8 -
# show cursor ?25h -
# restore main screen buffer ?1049 -
# restore screen ?47l
# enable line wrapoing ?7h
end(){ printf '\e8\e[?25h\e[?1049l\e8'&& exit ;}

((rows=LINES-1))
draw(){
  unset files

  y="$rows"
  [[ $PWD == / ]] && PWD=
  for fp in "$PWD"/*; do
    
    f="${fp##*/}" color=0

    if [[ -h $f ]]; then
      # symbolic link
      color=2 # green
    elif [[ -d $f ]]; then
      # directory
      color=4
    elif [[ -f $f ]]; then
      # regular file

      [[ $f == *.sh || -x $f ]]&& color=1 # executable
    fi

    files[$y]="$f"

    printf '\e[%dH\e[40;1;3%dm%s\e[m' "$y" "$color" "$f"

    ((y--))
  done
}; draw

hud(){
  printf '\e[%dE\e[2K\e[44m%s\e[m %s: %b' "$LINES" \
    'fm' '[←]back [→]open [q]uit' "$status"
}; hud

draw=1
cursor="$rows"

while read -rsn1; do
  [[ $REPLY == $'\e' ]]&& read -rsn2 # trap keys
  
  case ${REPLY^^} in
    Q) end;; # exit
    U) marked= status=;; # unmark
    D) # create directories
      printf '\n%s' 'New directory name: '
      read -r dir
      [[ $dir ]]&&{
        mkdir "$dir"

        # update hud status
        status="| \e[32mCreated\e[m: $dir"
      }
      clear
    ;;
    F) # create files
      printf '\n%s' 'New file name: '
      read -r file
      [[ file ]]&&{
        >"$file"

        # update hud status
        status="| \e[32mCreated\e[m: $file"
      }
      clear
    ;;
    H|B|\[D) cd ../&& clear&& draw;;
    J|\[B) ((cursor++));; # move down
    K|\[A) ((cursor--));; # move up
    X|\[3) # delete
      printf '\n%s' "Do you want to delete $marked? [y/n]: "
      read -rsn1 del
      [[ ${del,,} == 'y' ]]&&{
        # store pre-deleted path
        deleted="${PWD##*/}"
        rm -fr "$path/$marked"
        
        # update hud status
        status="| \e[31mDeleted\e[m: $marked"

        # move back if directory is gone
        [[ $marked == $deleted ]]&& cd ../ 
      }
      clear                                                ;;
    L|''|\[C) # marked files
      marked="${files[$cursor]}" path="$PWD"
      [[ $marked ]]&& status="| \e[33mMarked\e[m: $marked"

      if [[ -d ${files[$cursor]} ]]; then
        cd "${files[$cursor]}"
        # redraw the new files 
        clear&& draw
      
      elif [[ -e ${files[$cursor]} ]]; then
        draw=0 # disable draw
        # print file to main buffer for scroll
        printf '\e[?1049l\e[2J'
        cat "${files[$cursor]}"
        
        hud
       
        # trap a new set of commands for regular files
        while read -rsn1; do
          [[ $REPLY == $'\e' ]]&& read -rsn2
  
          case ${REPLY^^} in
            Q) clear&& end;;
            L|E|\[C) "${EDITOR:-vim}" "${files[$cursor]}";;
            B|\[D) draw=1&& break;; 
          esac

        done

      fi
    ;;
  esac

  # scrollback
  ((cursorMin=rows-${#files[@]}))
  if (( cursor >= LINES )); then
    ((cursor=cursorMin+1))
  elif (( cursor <= cursorMin )); then
    cursor="$rows"
  fi

  (( draw ))&&{
    draw

    printf '\e[%dH\e[44m%s\e[m' \
      "$cursor" "${files[$cursor]}"
    
    hud
  }
done
