#!/bin/bash
##
##  v1.31-2
##  Programa pensado na seguinte ordem de prioridade das operações:
##    marcar como feita - adicionar nova tarefa - remover tarefa - editar tarefa
##
##  $0 [COMANDOS]
##  COMANDOS:
##  edit                      -> Selecionar tarefas listadas (todas) para editar suas informações pelo vim/vi.
##  new                       -> Selecionar uma das seções listadas e abrir o editor de texto para inserir uma nova tarefa.
##  section [NAME]            -> Listar apenas as tarefas pendentes de uma seção. (Se NAME não for definido, lista as seções para a escolha pelas setas).
##  newsec <SECTION> <EMOJI>  -> Adicionar uma nova seção.
##
##  Ações diponíveis:
##  [ESC] cancelar tudo e fechar
##  [right-arrow/m] marca a tarefa (sobre o cursor) como "done"
##  [left-arrow/u] desmarca a tarefa (sobre o cursor)
##  [delete] (toggle) marcar tarefa (sobre o cursor) para remoção
##  [o] abrir o link da tarefa no navegador padrão
##  [enter/space] lista as alterações e espera a confirmação
##  [f] criar arquivo para a tarefa (se não existir) ~ a extensão do arquivo deve ser digitada logo após o beep, seguido de ENTER para finalizar
##  [d] criar diretório para a tarefa (se não existir) ~ o beep será emitido se for criado
##
##  known issues:
##  1- O prompt não é mostrado corretamente se a linha do comando que executou o script não for a primeira da janela do terminal;
##  2- Ao fechar o editor de texto (após a ação 'edit task') o prompt pode voltar com algumas linhas apagadas;
##


declare VI="vim"
declare OPEN="open"
command -v $VI >/dev/null 2>&1 || VI="vi"
command -v $OPEN >/dev/null 2>&1 || OPEN="cygstart"

[ "$DEBUG" ] ||  exec 2>/dev/null ## não exibir mostrar na STDOUT


## Safer shell scripting: https://sipb.mit.edu/doc/safe-shell
# set -euf -o pipefail
# set -e ## if a command fails (that is, it returns a non-zero exit status), the script exits (unless it is part of a iteration, &&, || command).

## prefer printf: https://askubuntu.com/questions/467747/which-is-better-printf-or-echo
## http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html


PATH_TO_TASKS_FILE="tests/texto_pos_grep.${1:-1}"
__debug.log() { echo -e "$(date +'[%M:%S]') $*" >> "__.logfile"; }
__debug.cursor() { echo -en "\E[6n"; read -sdR CURPOS; __debug.log "${CURPOS#*[}"; } ## (c) https://unix.stackexchange.com/questions/88296
__debug.loop() { while :; do :; done; }

# ------------------------------------------------------------------------------------------------------------------------------- #
declare -A COLORS=( [w]=$'\e[37;1m' [y]=$'\e[33m' [g]=$'\e[32m' [r]=$'\e[31m' [p]=$'\e[35;1m' [n]=$'\e[0m' [gr]=$'\e[30;1m' ) ## associative array
declare -A TASK_REF_EMOJIS=( [d]="file_folder" [f]="memo")
declare -A tasks_done=() ## chave é o seu index (no array de tarefas) e o valor é a sua linha real
declare -A tasks_to_remove=() ## chave é o seu index (no array de tarefas) e o valor é a sua linha real

declare -a HEADERS_E=("<!-- title -->\n" "<!-- last update -->\n" "<!-- snippet -->\n" "<!-- notes -->\n")

# declare -r NAVI_SYMBOL='\xC3\x97' #aka '×'
declare -r NAVI_SYMBOL='>'
declare -r NAVI_LENGTH=${#NAVI_SYMBOL} ## forçar tamanho aqui se for usar símbolo hexadecimal (UTF-8 literal)
declare -r NAVI_COLOR=${COLORS[y]}
declare -r NAVI_COLUMN=0
declare -r SEPARATOR='.'
declare -r KERNEL_NAME=$(uname -s)
declare -r NOT_MINGW_TERM="${KERNEL_NAME/#MINGW[[:digit:]]*}"

declare -r special_list="[|\`_*\[\]]"
declare -r CURR_DIR="${1%%/}"
declare -r TASKS_FILE="README.md"
declare -r MISCELLANEOUS_DIRNAME="avulsos"
# declare -r PATH_TO_TASKS_FILE="${CURR_DIR,,}/$TASKS_FILE"
declare -r PATH_TO_MISCELLANEOUS_DIRNAME="${CURR_DIR,,}/$MISCELLANEOUS_DIRNAME"
declare -a tasks_not_done
declare -a list_tasks_not_done
declare -i index
declare -i nums_tasks
declare -i offset
declare -i column_sep
declare -i screen_width
declare -l normalized_task_name
declare -l file
declare -l dir
declare -l task_ref ## file or directory to task notes (auto lower-case)
declare -l task_ref_emoji=""
declare SOF_CURSOR_POS
declare eof_cursor_pos
# ------------------------------------------------------------------------------------------------------------------------------- #

trap update_screen_width WINCH ## user has resized the window
trap clear_screen_exit SIGINT  ## user press Ctrl-C
# trap clear_screen_exit EXIT


main() {
  printf "\x1B[2J" ## apagar tela para previnir a issue#1
  # printf "\x1B[6n"; read -sdR SOF_CURSOR_POS
  SOF_CURSOR_POS="1;1"

  # tasks_not_done=$(grep --color=never -n -o -P '(?<=^\|\| \[).+(?=\])' "$PATH_TO_TASKS_FILE" | sed "s@\\\\\(${special_list}\)@\1@g" "$PATH_TO_TASKS_FILE") ## lista tarefas pendentes
  tasks_not_done=$(sed "s@\\\\\(${special_list}\)@\1@g" "$PATH_TO_TASKS_FILE")
  mapfile -t list_tasks_not_done <<< "$tasks_not_done"

  nums_tasks=${#list_tasks_not_done[@]} ## quantidade de linhas obtidas da extração das tarefas
  offset=$(( ${#nums_tasks} + ${NAVI_LENGTH} )) ## quantidade de colunas antes do 'SEPARATOR'
  column_sep=$(( $offset + 1 ))

  update_screen_width

  save_cursor
  gawk -v offset=$offset -v sep="$SEPARATOR" '{ printf "%*d%s %s\n", offset, NR, sep, gensub(/[0-9]+:/, "", 1) }' <<< "$tasks_not_done"
  update_eof_cursor_pos
  restore_cursor

  curr_task_index=0

  move_to_column $column_sep
  print_navi

  while read -rsn1 ui; do
    case "$ui" in
      $'\x1b') ## Handle ESC sequence.
        read -rsn2 -t 0.1 key
        # od -tx1 <<< "$key"
        [ "${key:0:1}" != '[' ] && bind_esc || {
          case "${key:1:1}" in
            'A') bind_arrow_up ;;
            'B') bind_arrow_down ;;
            'C') bind_arrow_right ;;
            'D') bind_arrow_left ;;
            '3') bind_delete ;;
          esac
        }
        # Flush "stdin" with 0.1  sec timeout.
        read -rsn5 -t 0.1 ;;

      $'') bind_blank ;;

      ## Handle especial alpha chars.
      $'\x64') bind_d ;;
      $'\x66') bind_f ;;
      $'\x6d') bind_m ;;
      $'\x6f') bind_o ;;
      $'\x75') bind_u ;;

      *) ;; # do nothing
    esac
  done
}


function set_file_and_dir {
  normalized_task_name=$(sed -r '
    y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
    y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜ/AAAAAAEEEEIIIIOOOOOUUUU/
    y/çÇñÑß¢Ðð£Øø§µÝý¥¹²³ªº/cCnNBcDdLOoSuYyY123ao/
    y/ /_/
    s_[:?"*<>|\/#]__g
    s_([^[:alnum:]])\1_\1_g' <<< "${1,,}")

  file="$PATH_TO_MISCELLANEOUS_DIRNAME/${normalized_task_name}.$2"
  dir="$CURR_DIR/${normalized_task_name}"
}

# --------------------------------------------------------- #

bind_arrow_up() { previous_task; }
bind_arrow_down() { next_task; }
bind_arrow_right() { mark_done_task; }
bind_arrow_left() { remove_done_mark; }
bind_m() { mark_done_task; }
bind_u() { remove_done_mark; }

bind_esc() { clear_screen_exit; }

bind_blank() {
  move_to_sof
  printf "\x1B[0J" ## apagar até o fim da tela
  # printf "\x1B[1G\x1B[0J" ## move cursor para a primeira linha e coluna do CLI e apaga até o fim da tela

  ## [11]TODO: chamar função que lista as alterações e esperar confirmação do usuário
  update_eof_cursor_pos

  exit 0
}

bind_delete() {
  ## verificando se já está marcado para remoção
  [ -n "${tasks_to_remove[$curr_task_index]+_}" ] && remove_delete_mark || mark_delete_task
}

bind_d() {
  set_file_and_dir "${list_tasks_not_done[curr_task_index]#*:}"
  # dir="$CURR_DIR/$normalized_task_name"
  dir="./$normalized_task_name"

  if [ ! -d "$dir" ]; then
    task_ref="./$normalized_task_name"
    task_ref_emoji="${TASK_REF_EMOJIS[d]}"

    mkdir -p "$dir"
    [ $? -eq 0 ] && emmitt_alert || return 1 ## ERROR
  fi
}

bind_f() {
  local extension=""

  emmitt_alert
  read -rs extension

  ## remover possíveis movimentos inválidos (uso das setas)
  extension="${extension//[[:cntrl:]]\[[[:alnum:]][[:punct:]]/}"
  extension="${extension//[[:cntrl:]]\[[[:alnum:]]/}"
  extension="${extension#.}" ## remover o ponto se iniciar na 'extension'

  if [ -n "$extension" ]; then
    set_file_and_dir "${list_tasks_not_done[curr_task_index]#*:}" "$extension"

    touch "$file"
    [ $? -eq 0 ] && emmitt_alert || return 1 ## ERROR
  fi
}

bind_o() {
  [ -n "$OPEN" ] || return 1

  local curr_task_line=${list_tasks_not_done[curr_task_index]%%:*}
  # local task_title=$(sed -rn "$curr_task_line s/(http[^\)]+).+$/\1/p" "$PATH_TO_TASKS_FILE")
  local task_title=$(sed -rn "$curr_task_line s/(http[^\)]+).+$/\1/p" tests/texto_base.1)
  local link_without_http="${task_title#*\(http}"

  if [ -n "$link_without_http" ]; then
    emmitt_alert
    $OPEN "http$link_without_http"
  fi
}

# --------------------------------------------------------- #


# ----------------------------------------------------- #

print_navi() {
  move_to_navi ${1}
  printf "%s${NAVI_SYMBOL}%s" ${NAVI_COLOR} ${COLORS[n]}
  move_to_column $column_sep ## desnecessário se o cursor estiver escondido
}

erase_navi() {
  move_to_navi
  printf "\x1B[${NAVI_LENGTH}X" ## escreve N brancos à direita
  # printf "\x1B[1P" ## apaga caractere à direita
  move_to_navi
}

move_to_navi() {
  [ "${1:-0}" -gt 0 ] && move_up_lines $1
  move_to_column $NAVI_COLUMN
}

mark_done_task() {
  [ -n "${tasks_done[$curr_task_index]+_}" ] && return ## verificando presença no array associativo
  tasks_done[$curr_task_index]="${list_tasks_not_done[curr_task_index]%%:*}" ## adicionando no array associativo
  unset tasks_to_remove[$curr_task_index] ## sobrescrevendo a ação 'remover tarefa'

  move_to_navi

  # local curr_task="${list_tasks_not_done[curr_task_index]}"
  local curr_task="${list_tasks_not_done[curr_task_index]#*:}"
  printf "%s%*d$SEPARATOR %s$curr_task%s" ${COLORS[g]} $offset $(( curr_task_index + 1 )) ${COLORS[gr]} ${COLORS[n]}

  local line_width=$(( $offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( $line_width / $screen_width )) ## quantas linhas a mais está ocupando

  # task_name="${line#*$SEPARATOR }"
  # task_num="${line%$SEPARATOR*}"
  # printf "%s${task_num}${SEPARATOR}%s ${task_name}%s" ${COLORS[g]} ${COLORS[gr]} ${COLORS[n]}

  print_navi $voffset
}

remove_done_mark() {
  [ -n "${tasks_done[$curr_task_index]+_}" ] || return ## verificando presença no array associativo
  unset tasks_done[$curr_task_index] ## removendo do array associativo

  move_to_navi

  # task_name="${line#*$SEPARATOR }"
  # task_num="${line%$SEPARATOR*}"
  # printf "%s${task_num}${SEPARATOR} ${task_name}" ${COLORS[n]}

  # local curr_task="${list_tasks_not_done[curr_task_index]}"
  local curr_task="${list_tasks_not_done[curr_task_index]#*:}"
  printf "%s%*d$SEPARATOR $curr_task%s" ${COLORS[n]} $offset $(( curr_task_index + 1 )) ${COLORS[n]}

  local line_width=$(( $offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( $line_width / $screen_width )) ## quantas linhas a mais está ocupando

  print_navi $voffset
}

mark_delete_task() {
  tasks_to_remove[$curr_task_index]="${list_tasks_not_done[curr_task_index]%%:*}" ## adicionando no array associativo
  unset tasks_done[$curr_task_index] ## sobrescrevendo a ação 'marcar como feita'

  move_to_navi

  local curr_task="${list_tasks_not_done[curr_task_index]#*:}"
  printf "%s%*d$SEPARATOR %s$curr_task%s" ${COLORS[r]} $offset $(( curr_task_index + 1 )) ${COLORS[gr]} ${COLORS[n]}

  local line_width=$(( $offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( $line_width / $screen_width )) ## quantas linhas a mais está ocupando

  print_navi $voffset
}

remove_delete_mark() {
  unset tasks_to_remove[$curr_task_index] ## removendo do array associativo

  move_to_navi

  local curr_task="${list_tasks_not_done[curr_task_index]#*:}"
  printf "%s%*d$SEPARATOR $curr_task%s" ${COLORS[n]} $offset $(( curr_task_index + 1 )) ${COLORS[n]}

  local line_width=$(( $offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( $line_width / $screen_width )) ## quantas linhas a mais está ocupando

  print_navi $voffset
}


next_task() {
  [ $(( curr_task_index + 1 )) -lt $nums_tasks ] || return
  erase_navi

  local curr_task="${list_tasks_not_done[curr_task_index]}"
  local line_width=$(( $offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( $line_width / $screen_width ))
  (( ++curr_task_index ))

  move_down_lines $(( $voffset + 1 ))
  print_navi
}

previous_task() {
  [ $curr_task_index -ne 0 ] || return
  erase_navi

  (( --curr_task_index ))
  local curr_task="${list_tasks_not_done[$curr_task_index]}"
  local line_width=$(( $offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( $line_width / $screen_width ))

  move_up_lines $(( $voffset + 1 ))
  print_navi
}

# ----------------------------------------------------- #

emmitt_alert() {
  printf "\007"
}

hide_cursor() {
  printf "\x1B[?25l"
}

show_cursor() {
  printf "\x1B[?12l\e[?25h"
}

clear_screen_exit() {
  printf "\n\x1B[0J" ## limpar até o fim da tela (representando a "parada" do programa)
  show_cursor

  __debug.log "\n---------- tasks done [${#tasks_done[@]}] ----------\
              \nk:> ${!tasks_done[@]}\
              \nv:> ${tasks_done[@]}\
              \n------- tasks to remove [${#tasks_to_remove[@]}] --------\
              \nk:> ${!tasks_to_remove[@]}\
              \nv:> ${tasks_to_remove[@]}"

  exit 0
}

save_cursor() {
  # tput sc
  printf "\x1B[s"
}

restore_cursor() {
  # tput rc
  printf "\x1B[u"
}

move_to_column() {
  # printf "\x1B[%dG" $((${1:-0} + 1))
  printf "\x1B[%dG" $((${1:-0}))
}

move_up_lines() {
  local lines=${1:-0}
  printf "\x1B[%dA" $lines
}

move_down_lines() {
  local lines=${1:-0}
  printf "\x1B[%dB" $lines
}

move_to_sof() {
  printf "\x1B[${SOF_CURSOR_POS:-1}f"
}

move_to_eof() {
  [[ -n "$NOT_MINGW_TERM" ]] || return 1 ## ERROR (não compatível com o MINGW)

  printf "\x1B[${eof_cursor_pos%;*};1f"

  : '
  ## DEBUG things
  printf "12345"
  printf "\x1B[1G" ## vai pra coluna 1
  # printf "\x1B[3X" ## insere 3 espaços à direita
  printf "\x1B[3P" ## apaga 3 caracteres à direita
  '
}

erase_to_eol() {
  printf "\x1B[K"
}

update_eof_cursor_pos() {
  [[ -n "$NOT_MINGW_TERM" ]] || return 1 ## ERROR (não compatível com o MINGW)

  printf "\x1B[6n"
  read -sdR eof_cursor_pos
  eof_cursor_pos="${eof_cursor_pos#*[}"
}

update_screen_width() {
  # windown_lines=`tput lines`
  # windown_cols=`tput cols`
  screen_width=$(tput cols)
  # count_column_left=$(( $screen_width - $count_column_width ))
}


####
main
####
