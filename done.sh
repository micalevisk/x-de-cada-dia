#!/bin/bash
##
##  [done.sh]
##  Created by Micael Levi on 12/17/2017
##  Copyright (c) 2017 mllc@icomp.ufam.edu.br; All rights reserved.
##
##  Recebe o nome do diretório raiz que contém do README.md
##  para marcar uma tarefa (não feita) como feita,
##  e/ou atualizar o contador (na badge) de tarefas prontas e totais.
##  Além de opcionalmente realizar o commit, push.
##  Não admite nomes repetidos de tarefas, visto que apenas os nomes
##  serão exibidos, tornando a identificação impossível.
##
##  using:
##  echo, grep, sed, mapfile, awk, read, git
##

GIT_MSG="${2:-one done}"
TASKS_FILE="README.md"
MISCELLANEOUS_FILENAME="avulsos"
TASK_DONE_MARK=":white_check_mark:"
CURR_DIR="${1%%/}"
PATH_TO_TASKS_FILE="${CURR_DIR,,}/$TASKS_FILE"
MISCELLANEOUS_DIR="${CURR_DIR,,}/$MISCELLANEOUS_FILENAME"
declare -A COLORS=( [w]=$'\e[37;1m' [y]=$'\e[33;1m' [g]=$'\e[32;1m' [r]=$'\e[31;1m' [p]=$'\e[35;1m' [n]=$'\e[0m' [gr]=$'\e[30;1m' )


[ $# -ne 1 ] && { echo -e "usage: \e[36m$0\e[0m \e[35;1m<lang_directory>\e[0m \e[35m[commit_message]\e[0m"; exit 1; }
[ -w "$PATH_TO_TASKS_FILE" ] || exit 2 ## TODO: indiciar que o arquivo não existe para escrita


set_file_and_dir() {
  local task_name="${tasks_not_done[$num_task]}"

  normalized_task_name=$(sed -r '
    y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
    y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜ/AAAAAAEEEEIIIIOOOOOUUUU/
    y/çÇñÑß¢Ðð£Øø§µÝý¥¹²³ªº/cCnNBcDdLOoSuYyY123ao/
    y/ /_/
    s_[:?"*<>|\/#]__g
    s_([^[:alnum:]])\1_\1_g' <<< "${task_name,,}")

  file="$MISCELLANEOUS_DIR/${normalized_task_name}.$extension"
  dir="$CURR_DIR/${normalized_task_name}"
}

confirm() {
  read -n1 -p "$1? ${COLORS[r]}(y/N)${COLORS[n]} "
  [ "${REPLY,,}" == "y" ]
}


list_not_done=$(grep --color=never -o -P '(?<=^\|\| \[).+(?=\])' "$PATH_TO_TASKS_FILE")
mapfile -t tasks_not_done <<< "$list_not_done"
nums_tasks=$(grep -c -P '^[:|].+\[.+\]\(.+\).+\|' "$PATH_TO_TASKS_FILE")
nums_tasks_done=$(( nums_tasks - ${#tasks_not_done[@]} ))


awk '{ print NR ".\t" $0 } END { print "\n" }' <<< "$list_not_done"
read -a task_metadata -p "[${COLORS[p]}task${COLORS[n]}] [${COLORS[p]}extension${COLORS[n]}] = "

num_task=$((task_metadata[0]-1))
extension=${task_metadata[1]}
task_name=${tasks_not_done[num_task]}

## TODO: retornar para o 'read' se o número dado for inválido
[ $num_task -lt ${#tasks_not_done[*]} ] || exit 3

if [ -n "${task_metadata[0]}" ]
then
  _line_selected_task=$(grep --color=never -n -m1 -F "$task_name" "$PATH_TO_TASKS_FILE")
  line_selected_task="${_line_selected_task%%:*}"

  ## TODO: retornar para o 'read' se a resposta for N
  if confirm "${COLORS[w]}Task ${COLORS[y]}${task_name}${COLORS[w]} was done"
  then
    set_file_and_dir

    sed -i "${line_selected_task} s/^||/${TASK_DONE_MARK} |/" "$PATH_TO_TASKS_FILE" && ((nums_tasks_done++))

    [ -n "$extension" -a -e "$file" ] && { task_ref="./$MISCELLANEOUS_FILENAME/${normalized_task_name}.$extension"; emoji="memo"; }
    [ -d "$dir" ] && { task_ref="./$normalized_task_name"; emoji="file_folder"; }

    [ -n "$task_ref" ] && sed -i "${line_selected_task} s%$% [:${emoji}:](${task_ref})%" "$PATH_TO_TASKS_FILE"
  fi
fi


percentage=$(( nums_tasks_done*100/nums_tasks ))
[[ percentage -eq 100 ]] && opt='g'

## altera a primeira ocorrência, ie., atualiza apenas 1 badge
sed -i -r "
  0,/(done-)[0-9]+(.+)\([0-9]+(.+of...)[0-9]+\)/ s//\1${percentage}\2(${nums_tasks_done}\3${nums_tasks})/
" "$PATH_TO_TASKS_FILE" && echo -e "\n${COLORS[w]}Now ${COLORS[${opt:-r}]}${percentage}% ${COLORS[w]}(${nums_tasks_done} of ${nums_tasks}) done!${COLORS[n]}"


## ----------------- EXTRA ----------------- ##
# git ls-files -m
# git status -s "$PATH_TO_TASKS_FILE" | sed -n '1q1'

if ! git diff --exit-code -s "$PATH_TO_TASKS_FILE" && confirm "${COLORS[w]}Do ${COLORS[y]}git add ${PATH_TO_TASKS_FILE}${COLORS[w]}"
then
  echo
  git add -v "$PATH_TO_TASKS_FILE" && \
  git commit -vm "$GIT_MSG" && \
  confirm "${COLORS[w]}Do ${COLORS[y]}git push${COLORS[w]}" && \
  git push -v || echo -e "\n${COLORS[gr]}Not pushed...${COLORS[n]}"
fi
