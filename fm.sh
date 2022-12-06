#!/bin/bash

# terminal window cells
term_size(){ IFS='[;' read -sp $'\e7\e[9999;9999H\e[6n\e8' -d R -rs _ LINES _ ;}; term_size

# save cursor: position 7 -
# save screen: ?47h
# hide cursor: ?25l -
# set alternative screen buffer: ?1049h -
# disable line wrapping: ?7l
printf '\e7\e[?25l'

# wipe terminal screen
clear(){ printf '\e[2J' ;}

# restore cursor position: 8 -
# show cursor: ?25h -
# restore main screen buffer: ?1049l -
# restore screen: ?47l
# enable line wrapoing: ?7h
end(){ printf '\e[?25h\e8'&& exit ;}

declare -A files
((rows=LINES-1)) # limit screen size for status bar
draw_files(){
  unset files # reset file array

  # inital array index
  y="$rows"

  [[ $PWD == / ]] && PWD= # if root, hide /
  for fp in "$PWD"/*; do
   
    f="${fp##*/}" # strip full file path
    if [[ -h $f ]]; then
      # symbolic link
      # 9: seafoam  5: cyan
      [[ $TERM =~ 256 ]]&& f="38;5;42m$f" ||
        f="35m$f"
    elif [[ -f $f && -x $f || $f == *'.sh' ]]; then
      # executable
      # 210: red-orange  1: red
      [[ $TERM =~ 256 ]]&& f="38;5;210m$f" ||
        f="32m$f"
    elif [[ -d $f ]]; then
      # directory
      # 147: blurple  # 4: blue
      [[ $TERM =~ 256 ]]&& f="38;5;147m$f" ||
        f="34m$f"
    else # regular file or anything else
      # 248: grey  # 7;2: dim white
      [[ $TERM =~ 256 ]]&& f="38;5;248m$f" ||
        f="37;2m$f"
    fi

    # draw the files
    printf '\e[%dH\e[%s\e[m' "$y" "$f"

    # store files into an indexed (associative) array
    files["$y"]="${f#[0-9]*m}"

    # set highlighted color to file color
    hover["$y"]="${f%%${files[$cursor]}}"

    # iterate the array per file
    ((y--))
    #(( y == 0 ))&& y="$rows"
  done
}; draw_files

hud(){ # status bar
  # move down to start of $LINES: E
  # clear line: 2K
  printf '\e[%dE\e[2K\e[1;44m%s\e[m %s: %b' "$LINES" \
    'fm' '[←]back [→]open [q]uit' "$status"
}; hud

draw=1 # enable draw
#cursor="$rows" # start cursor above status bar

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
      [[ $file ]]&&{
        >"$file"

        # update hud status
        status="| \e[32mCreated\e[m: $file"
      }
      clear
    ;;
    H|B|\[D) cd ../&& clear&& draw_files;;
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
        clear&& draw_files
      
      elif [[ -e ${files[$cursor]} ]]; then
        draw=0 # disable draw
        # print file to main buffer
        #printf '\e[?1049l\e[2J\r'

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
    draw_files

    printf '\e[%dH\e[%s%s\e[m' \
      "$cursor" "${hover[$cursor]/#3/4}" \
      "${files[$cursor]}"
    
    hud
  }
done

# trap interrupt and abort signals
trap '' 2 9
# trap window resize
trap 'term_size; clear; draw_files; hud' 28
