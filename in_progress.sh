#!/bin/bash
##
##  [in_progress.sh]
##  Created by Micael Levi on 17/12/2017
##  Copyright (c) 2017 mllc@icomp.ufam.edu.br; All rights reserved.
##
##  Recebe o nome do diretório raiz que contém do README.md
##  Para criar um arquivo ou diretório que irá conter
##  arquivos relativos a uma tarefa não feita.
##
##  using:
##  echo, sed, mapfile, awk, read, mkdir, touch
##


FILE="README.md"
CURR_DIR="${1%%/}"
PATH_TO_FILE="$CURR_DIR/$FILE"

test $# -ne 1 && {
  echo -e "usage: \e[36m$0\e[0m \e[35;1m<lang_directory>\e[0m"
  exit 1
}
test -w "$PATH_TO_FILE" || exit 2 ## TODO: indiciar que o arquivo não existe para escrita

declare -a tasks_not_done
declare -i nums_tasks num_task
declare -x extension list_not_done
declare -f set_file_and_dir confirm


function set_file_and_dir() {
  local task_name="${tasks_not_done[$num_task]}"

  local normalized=$(sed -r '
    y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
    y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜ/AAAAAAEEEEIIIIOOOOOUUUU/
    y/çÇñÑß¢Ðð£Øø§µÝý¥¹²³ªº/cCnNBcDdLOoSuYyY123ao/
    y/ /_/
    s_[:?"*<>|\/]__g
    s_(.)\1_\1_g
  ' <<< "${task_name,,}")

  file="$CURR_DIR/${normalized}.$extension"
  dir="$CURR_DIR/${normalized}"
}

function confirm() {
  read -n1 -p "$1? (y/N) "
  [[ "${REPLY,,}" == "y" ]] || exit 3
}


list_not_done=$(grep -P -o '(?<=- \[ \] \[).+(?=\])' "$PATH_TO_FILE")
mapfile -t tasks_not_done <<< "$list_not_done"
nums_tasks=$(grep -Pc '^- \[.\].+' "$PATH_TO_FILE")


awk '{ print NR ":\t" $0 } END { print "\n" }' <<< "$list_not_done"
read -a task_metadata -p "<task> [extension] = "

num_task=$((task_metadata[0]-1))
extension=${task_metadata[1]}

## TODO: retornar para o 'read' se o número dado for inválido
[[ $num_task -lt ${#tasks_not_done[*]} && -n ${task_metadata[0]} ]] || exit 4

set_file_and_dir

## TODO: se a resposta não for 'y', então voltar para o 'read'
if [[ -z "$extension" ]]; then
  confirm "Create directory \"$dir/\""
  mkdir -p "$dir"
else
  confirm "Create file \"$file\""
  touch "$file"
fi
