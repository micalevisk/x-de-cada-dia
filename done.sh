#!/bin/bash
##
##  [done.sh]
##  Created by Micael Levi on 17/12/2017
##  Copyright (c) 2017 mllc@icomp.ufam.edu.br; All rights reserved.
##
##  Recebe o nome do diretório raiz que contém do README.md
##  Para marcar uma tarefa (não feita) como feita,
##  e/ou só atualizar o contador (badge) de tarefas prontas.
##
##  using:
##  echo, sed, mapfile, awk, read
##


FILE="README.md"
CURR_DIR="${1%%/}"
PATH_TO_FILE="$CURR_DIR/$FILE"

test $# -ne 1 && {
  echo -e "usage: \e[36m$0\e[0m \e[35;1m<lang_directory>\e[0m"
  exit 1
}
test -w "$PATH_TO_FILE" || exit 2 ## TODO: indiciar que o arquivo não existe para escrita

declare -a tasks
declare -i nums_tasks nums_tasks_done num_task line_selected_task
declare -x percentage list_not_done task_name
# declare -A cores=( ["clojure"]="DB5855" ["ruby"]="701516" ["elixir"]="6E4A7E" ["go"]="375EAB" )


list_not_done=$(grep -P -o '(?<=- \[ \] \[).+(?=\])' "$PATH_TO_FILE")
mapfile -t tasks <<< "$list_not_done"
nums_tasks=${#tasks[*]}


awk '{ print NR ":\t" $0 } END { print "\n" }' <<< "$list_not_done"
read -a task_metadata -p "[task] done = "

num_task=$((task_metadata[0]-1))
task_name=${tasks[num_task]}

## TODO: retornar para o 'read' se o número dado for inválido
[[ $num_task -lt $nums_tasks ]] || exit 3

line_selected_task=$(grep -n -m1 -F "$task_name" "$PATH_TO_FILE" | cut -d: -f1)

if [[ -n "${task_metadata[0]}" ]]; then
  read -n1 -p "Task \"$task_name\" was done? (y/N) "
  [[ "${REPLY,,}" == "y" ]] && sed -i "${line_selected_task}s/\[ \]/[x]/" "$PATH_TO_FILE"
fi


nums_tasks_done=$(grep -P -c '^- \[x\] \[.+' "$PATH_TO_FILE")
percentage=$(( nums_tasks_done*100/nums_tasks ))

sed -i -r "
  s/done-[0-9]+%/done-${percentage}%/
  t end
  :end
" "$PATH_TO_FILE" && echo -e "\nNow: ${percentage}% done!"
