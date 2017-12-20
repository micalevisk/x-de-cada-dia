#!/bin/bash
##
##  [done.sh]
##  Created by Micael Levi on 12/17/2017
##  Copyright (c) 2017 mllc@icomp.ufam.edu.br; All rights reserved.
##
##  Recebe o nome do diretório raiz que contém do README.md
##  Para marcar uma tarefa (não feita) como feita,
##  e/ou só atualizar o contador (badge) de tarefas prontas.
##
##  using:
##  echo, grep, cut, sed, mapfile, awk, read
##


FILE="README.md"
MISCELLANEOUS="avulsos"
CURR_DIR="${1%%/}"
PATH_TO_FILE="${CURR_DIR,,}/$FILE"
MISCELLANEOUS_DIR="${CURR_DIR,,}/$MISCELLANEOUS"


[[ $# -ne 1 ]] && { echo -e "usage: \e[36m$0\e[0m \e[35;1m<lang_directory>\e[0m"; exit 1; }
[[ -w "$PATH_TO_FILE" ]] || exit 2 ## TODO: indiciar que o arquivo não existe para escrita


declare -A COLORS=( [w]=$'\e[37;1m' [y]=$'\e[33;1m' [g]=$'\e[32;1m' [r]=$'\e[31;1m' [p]=$'\e[35;1m' [n]=$'\e[0m' )
declare -a tasks_not_done
declare -i nums_tasks nums_tasks_done num_task line_selected_task
declare -x percentage list_not_done task_name normalized_task_name file dir task_ref emoji
declare -f set_file_and_dir


function set_file_and_dir() {
  local task_name="${tasks_not_done[$num_task]}"

  normalized_task_name=$(sed -r '
    y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
    y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜ/AAAAAAEEEEIIIIOOOOOUUUU/
    y/çÇñÑß¢Ðð£Øø§µÝý¥¹²³ªº/cCnNBcDdLOoSuYyY123ao/
    y/ /_/
    s_[:?"*<>|\/]__g
    s_([^[:alnum:]])\1_\1_g' <<< "${task_name,,}")

  file="$MISCELLANEOUS_DIR/${normalized_task_name}.$extension"
  dir="$CURR_DIR/${normalized_task_name}"
}


list_not_done=$(grep -P -o '(?<=- \[ \] \[).+(?=\])' "$PATH_TO_FILE")
mapfile -t tasks_not_done <<< "$list_not_done"
nums_tasks=$(grep -Pc '^- \[.\].+' "$PATH_TO_FILE")


awk '{ print NR ":\t" $0 } END { print "\n" }' <<< "$list_not_done"
read -a task_metadata -p "[${COLORS[p]}task${COLORS[n]}] [${COLORS[p]}extension${COLORS[n]}] = "

num_task=$((task_metadata[0]-1))
extension=${task_metadata[1]}
task_name=${tasks_not_done[num_task]}

## TODO: retornar para o 'read' se o número dado for inválido
[[ $num_task -lt ${#tasks_not_done[*]} ]] || exit 3

line_selected_task=$(grep -n -m1 -F "$task_name" "$PATH_TO_FILE" | cut -d: -f1)

if [[ -n ${task_metadata[0]} ]]; then
  ## TODO: retornar para o 'read' se a resposta for N
  read -n1 -p "${COLORS[w]}Task ${COLORS[y]}${task_name}${COLORS[w]} was done? ${COLORS[r]}(y/N)${COLORS[n]} "

  if [[ "${REPLY,,}" == "y" ]]; then
    set_file_and_dir

    sed -i "${line_selected_task} s/\[ \]/[x]/" "$PATH_TO_FILE"

    [[ -n "$extension" && -e "$file" ]] && { task_ref="./$MISCELLANEOUS/${normalized_task_name}.$extension"; emoji="memo"; }
    [[ -d "$dir"  ]] && { task_ref="./$normalized_task_name"; emoji="file_folder"; }

    [[ -n "$task_ref" ]] && sed -ri "${line_selected_task} s%$% [:${emoji}:](${task_ref})%" "$PATH_TO_FILE"
  fi
fi


nums_tasks_done=$(grep -Pc '^- \[x\].+' "$PATH_TO_FILE")
percentage=$(( nums_tasks_done*100/nums_tasks ))
[[ percentage -eq 100 ]] && opt='g'

sed -i -r "
  s/done-[0-9]+%/done-${percentage}%/
  t end
  :end
" "$PATH_TO_FILE" && echo -e "\n${COLORS[w]}Now ${COLORS[${opt:-r}]}${percentage}% ${COLORS[w]}done!${COLORS[n]}"
