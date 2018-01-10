#!/bin/bash
##
##  [in_progress.sh]
##  Copyright (c) 2017, Micael Levi <mykael2010@hotmail.com>
##  All rights reserved.
##
##  Recebe o nome do diretório raiz que contém do README.md
##  Para criar um arquivo ou diretório que irá conter
##  arquivos relativos a uma tarefa não feita.
##
##  using:
##  echo, grep, sed, mapfile, awk, read, mkdir, touch
##

TASKS_FILE="README.md"
MISCELLANEOUS_DIRNAME="avulsos"
CURR_DIR="${1%%/}"
PATH_TO_TASKS_FILE="${CURR_DIR,,}/$TASKS_FILE"
MISCELLANEOUS_DIR="${CURR_DIR,,}/$MISCELLANEOUS_DIRNAME"
declare -A COLORS=( [w]=$'\e[37;1m' [y]=$'\e[33;1m' [g]=$'\e[32;1m' [r]=$'\e[31;1m' [p]=$'\e[35;1m' [n]=$'\e[0m' [gr]=$'\e[30;1m' )


[ $# -ne 1 ] && { echo -e "usage: \e[36m$0\e[0m \e[35;1m<lang_directory>\e[0m"; exit 1; }
[ -w "$PATH_TO_TASKS_FILE" ] || exit 2 ## TODO: indiciar que o arquivo não existe para escrita


function set_file_and_dir {
  local task_name="${tasks_not_done[$num_task]}"

  local normalized=$(sed -r '
    y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
    y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜ/AAAAAAEEEEIIIIOOOOOUUUU/
    y/çÇñÑß¢Ðð£Øø§µÝý¥¹²³ªº/cCnNBcDdLOoSuYyY123ao/
    y/ /_/
    s_[:?"*<>|\/#]__g
    s_([^[:alnum:]])\1_\1_g' <<< "${task_name,,}")

  file="$MISCELLANEOUS_DIR/${normalized}.$extension"
  dir="$CURR_DIR/${normalized}"
}

function confirm {
  read -n1 -p "$1? ${COLORS[r]}(y/N)${COLORS[n]} "
  [[ "${REPLY,,}" == "y" ]] || exit 3
}


list_not_done=$(grep --color=never -o -P '(?<=^\|\| \[).+(?=\])' "$PATH_TO_TASKS_FILE")
mapfile -t tasks_not_done <<< "$list_not_done"
nums_tasks=$(grep -c -P "^[${TASK_DONE_MARK:0:1}|].+\[.+\]\(.+\).+\|" "$PATH_TO_TASKS_FILE")

## display all pending tasks
awk '{ printf "%3s:\t%s\n", NR, $0 } END { print "" }' <<< "$list_not_done"
read -a task_metadata -p "<${COLORS[r]}task${COLORS[n]}> [${COLORS[p]}extension${COLORS[n]}] = "

num_task=$((task_metadata[0]-1))
extension=${task_metadata[1]}

## TODO: retornar para o 'read' se o número dado for inválido
[ $num_task -lt ${#tasks_not_done[*]} -a -n ${task_metadata[0]} ] || exit 4

set_file_and_dir

## TODO: se a resposta não for 'y', então voltar para o 'read'
if [ -n "$extension" ]
then
  confirm "${COLORS[w]}Create file ${COLORS[y]}${file}${COLORS[w]}"
  mkdir -p "$MISCELLANEOUS_DIR" && touch "$file" && echo -e "\n${COLORS[w]}Created file ${COLORS[y]}${file} ${COLORS[n]}"
else
  confirm "${COLORS[w]}Create directory ${COLORS[y]}$dir/${COLORS[w]}"
  mkdir -p "$dir" && echo -e "\n${COLORS[w]}Created directory ${COLORS[y]}${dir} ${COLORS[n]}"
fi
