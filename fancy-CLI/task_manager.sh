#!/bin/bash
##
##  v1.31-2
##  resources for cursor movements with ANSI escape sequences and other stuffs:
##  - http://shellscript.com.br
##  - https://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html
##  - https://www.youtube.com/watch?v=K_6peGEsq0U
##  - https://github.com/piotrmurach/tty-cursor/tree/master/spec/unit
##  - https://unix.stackexchange.com/questions/88296
##  - https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
##  - https://stackoverflow.com/questions/32009787
##  - https://developer.apple.com/library/content/documentation/OpenSource/Conceptual/ShellScripting/AdvancedTechniques/AdvancedTechniques.html
##  - https://www.gnu.org/software/bash/manual/html_node/Job-Control.html
##
##  Programa pensado na seguinte ordem de prioridade das operações:
##    marcar como feita - adicionar nova tarefa - remover tarefa - editar tarefa
##
##  $0 [COMANDOS]
##  COMANDOS:
##  edit                      -> Selecionar tarefas listadas (todas) para editar suas informações pelo vim/vi.
##  new                       -> Selecionar uma das seções listadas e abrir o editor de texto para inserir uma nova tarefa.
##  section [NAME]            -> Listar apenas as tarefas pendentes de uma seção. (Se NAME não for definido, lista as seções para a escolha pelas setas).
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
##  3- Não apaga o diretório/arquivo criado (antes) para uma tarefa caso o usuário deseja (agora) removê-la;
##


declare VI="vim"
declare OPEN="open"
command -v $VI >/dev/null 2>&1 || VI="vi"
command -v $OPEN >/dev/null 2>&1 || OPEN="cygstart"

exec 2>/dev/null ## não mostrar erros na saída padrão


PATH_TO_TASKS_FILE="tests/texto_pos_grep.${1:-1}"
__debug.log() { echo -e "$(date +'[%M:%S]') $*" >> "__.logfile"; }
__debug.cursor() { echo -en "\E[6n"; read -sdR CURPOS; __debug.log "${CURPOS#*[}"; } ## (c) https://unix.stackexchange.com/questions/88296
__debug.loop() { while :; do :; done; }

# ------------------------------------------------------------------------------------------------------------------------------- #
declare -A COLORS=( [w]=$'\e[37;1m' [y]=$'\e[33m' [g]=$'\e[32m' [r]=$'\e[31m' [p]=$'\e[35;1m' [n]=$'\e[0m' [gr]=$'\e[30;1m' )
declare -A TASK_REF_EMOJIS=( [d]="file_folder" [f]="memo")
declare -A tasks_done ## a chave é o seu index (no array de tarefas) e o valor é a sua linha real
declare -A tasks_to_remove ## a chave é o seu index (no array de tarefas) e o valor é a sua linha real
declare -A created_files ## a chave é a linha real da tarefa e o valor é o caminho para o arquivo
declare -A created_dirs ## a chave é a linha real da tarefa e o valor é o caminho para o diretório

declare -a HEADERS_E=("<!-- title -->\n" "<!-- last update -->\n" "<!-- snippet -->\n" "<!-- notes -->\n")
declare -a tasks_not_done
declare -a list_tasks_not_done

# declare -r NAVI_SYMBOL='\xC3\x97' #aka '×'
declare -r NAVI_SYMBOL='>'
declare -r NAVI_LENGTH=${#NAVI_SYMBOL} ## forçar tamanho aqui se for usar símbolo hexadecimal (UTF-8 literal)
declare -r NAVI_COLOR=${COLORS[y]}
declare -r NAVI_COLUMN=0
declare -r SEPARATOR='.'
declare -r KERNEL_NAME="$(uname -s)"
declare -r NOT_MINGW_TERM="${KERNEL_NAME/#MINGW[[:digit:]]*}"
declare -r special_list="[|\`_*\[\]]"
declare -r CURR_DIR="${1%%/}"
declare -r TASKS_FILE="README.md"
declare -r MISCELLANEOUS_DIRNAME="avulsos"
declare -r TASK_DONE_MARK=":white_check_mark:"
# declare -r PATH_TO_TASKS_FILE="${CURR_DIR,,}/$TASKS_FILE"
declare -r PATH_TO_MISCELLANEOUS_DIRNAME="${CURR_DIR,,}/$MISCELLANEOUS_DIRNAME"

declare -i index
declare -i nums_tasks_not_done
declare -i offset
declare -i column_sep
declare -i screen_width

declare -l normalized_task_name
declare -l file
declare -l dir

declare SOF_CURSOR_POS
declare eof_cursor_pos
# ------------------------------------------------------------------------------------------------------------------------------- #

trap update_screen_width! WINCH ## user has resized the window
trap clear_screen_exit SIGINT  ## user press Ctrl-C
trap clear_screen_exit SIGTSTP SIGHUP SIGKILL SIGQUIT SIGTERM ## user press Ctrl-Z or quit this process

# ===================================================== #
# ===================== begin ========================= #
# @use: gwak                                            #
# ===================================================== #
main() {
  clear ## apagar tela para previnir a issue#1 ~ movee o cursor para (1,1)
  SOF_CURSOR_POS="1;1"
  # printf "\\e[6n"; read -sdR SOF_CURSOR_POS

  # tasks_not_done=$(grep --color=never -n -o -P '(?<=^\|\| \[).+(?=\])' "$PATH_TO_TASKS_FILE" | sed "s@\\\\\(${special_list}\)@\1@g") ## lista tarefas pendentes
  tasks_not_done=$(sed "s@\\\\\(${special_list}\)@\1@g" "$PATH_TO_TASKS_FILE")
  mapfile -t list_tasks_not_done <<< "$tasks_not_done"

  [ -n "${list_tasks_not_done[0]//[[:blank:]]/}" ] || bind_blank

  nums_tasks_not_done=${#list_tasks_not_done[@]} ## quantidade de linhas obtidas da extração das tarefas
  offset=$(( ${#nums_tasks_not_done} + ${NAVI_LENGTH} )) ## quantidade de colunas antes do 'SEPARATOR'
  column_sep=$(( $offset + 1 ))

  update_screen_width!

  save_cursor
  gawk -v offset=$offset -v sep="$SEPARATOR" '{ printf "%*d%s %s\n", offset, NR, sep, gensub(/[0-9]+:/, "", 1) }' <<< "$tasks_not_done"
  update_eof_cursor_pos!
  restore_cursor
  hide_cursor

  curr_task_index=0
  move_to_column $column_sep
  print_navi

  while read -rsn1 ui; do
    case "$ui" in
      $'\x1b') ## handle ESC sequence.
        read -rsn2 -t 0.1 key
        [ "${key:0:1}" != '[' ] && bind_esc || {
          case "${key:1:1}" in
            'A') bind_arrow_up ;;
            'B') bind_arrow_down ;;
            'C') bind_arrow_right ;;
            'D') bind_arrow_left ;;
            '3') bind_delete ;;
          esac
        }
        ## flush "stdin" with 0.1  sec timeout.
        read -rsn5 -t 0.1 ;;

      $'') bind_blank ;;

      ## handle especial alpha chars.
      $'\x64') bind_d ;;
      $'\x66') bind_f ;;
      $'\x6d') bind_m ;;
      $'\x6f') bind_o ;;
      $'\x75') bind_u ;;

      *) ;; ## do nothing
    esac
  done
}


# ====================================================== #
# ====================== util ========================== #
# ====================================================== #

## Exibe um mensagem que espera a tecla 'y' (1 caractere) da stdin.
## @args: <pergunta que será feita>
## @use: read
confirm() {
  read -n1 -p "$1? ${COLORS[r]}[y/N]${COLORS[n]} " 2>&1
  [ "${REPLY,,}" == "y" ]
}

## Definie as variáveis 'file' e 'dir' que são caminhos para o
## arquivo ou diretório da tarefa. Além da variável
## 'normalized_task_name' que guarda o nome tratado da tarefa.
## @args: <nome da tarefa> [extensão para o arquivo]
## @use: sed
set_file_and_dir!() {
  normalized_task_name=$(sed -E '
    y/àáâãäåèéêëìíîïòóôõöùúûü/aaaaaaeeeeiiiiooooouuuu/
    y/ÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜ/AAAAAAEEEEIIIIOOOOOUUUU/
    y/çÇñÑß¢Ðð£Øø§µÝý¥¹²³ªº/cCnNBcDdLOoSuYyY123ao/
    y/ /_/
    s_[:?"*<>|\/#]__g
    s_([^[:alnum:]])\1_\1_g' <<< "${1,,}")

  file="$PATH_TO_MISCELLANEOUS_DIRNAME/${normalized_task_name}.$2"
  dir="$CURR_DIR/${normalized_task_name}"
}


# ===================================================== #
# ==================== binding ======================== #
# ===================================================== #

bind_arrow_up() { previous_task; }
bind_arrow_down() { next_task; }
bind_arrow_right() { mark_done_task; }
bind_arrow_left() { remove_done_mark; }
bind_m() { mark_done_task; }
bind_u() { remove_done_mark; }

bind_esc() { clear_screen_exit; }

## Etapa final que lista os diretórios e arquivos criados,
## espera a confirmação das ações realizadas e atualiza o
## arquivo das tarefas (progresso, etc).
## @use: sed printf
bind_blank() {
  move_to_eof || {
    move_to_sof ## para a versão no MinGW
    printf "\\e[0J" ## apagar até o fim da tela
  }

  show_cursor

  # local nums_tasks=$(grep -c -P "^\s*(${TASK_DONE_MARK}|\|\|)" "$PATH_TO_TASKS_FILE")
  local nums_tasks=$(grep -c -P "^\s*(${TASK_DONE_MARK}|\|\|)" "tests/texto_base.1")
  local nums_tasks_done=$(( nums_tasks - nums_tasks_not_done ))

  [ ${#created_dirs[@]} -ne 0 ] && {
    printf "~ Diretórios Criados (${#created_dirs[@]}):\n"
    printf "%s\n" "${created_dirs[@]}"
  }

  [ ${#created_files[@]} -ne 0 ] && {
    printf "~ Arquivos Criados   (${#created_files[@]}):\n"
    printf "%s\n" "${created_files[@]}"
  }

  [ ${#tasks_done[@]} -ne 0 ] && {
    confirm "~ ${#tasks_done[@]} Tarefa(s) Feita(s)" && {
      local emoji task_ref

      for real_line in "${tasks_done[@]}"; do
        # sed -i "${real_line} s/^||/${TASK_DONE_MARK} |/" "$PATH_TO_TASKS_FILE" && ((nums_tasks_done++))
        sed -i "${real_line} s/^\s*||/${TASK_DONE_MARK} |/" "tests/texto_base.1" && ((nums_tasks_done++))

        ## referenciando o arquivo/diretório criado para esta tarefa
        if [ -n "${created_files[$real_line]+_}" ]; then
          sed -i "${real_line} s%$% [:${TASK_REF_EMOJIS[f]}:](${created_files[$real_line]})%" "tests/texto_base.1"
        elif [ -n "${created_dirs[$real_line]+_}" ]; then
          sed -i "${real_line} s%$% [:${TASK_REF_EMOJIS[d]}:](${created_dirs[$real_line]})%" "tests/texto_base.1"
        fi
      done
    }

    printf "\n"
  }

  [ ${#tasks_to_remove[@]} -ne 0 ] && {
    confirm "~ ${#tasks_to_remove[@]} Tarefa(s) Removidas(s)" && {
      local lines_to_delete="${tasks_to_remove[@]/%/d;}"
      # sed -i "$lines_to_delete" "$PATH_TO_TASKS_FILE" && nums_tasks="$(( nums_tasks - ${#tasks_to_remove[@]} ))"
      sed -i "$lines_to_delete" "tests/texto_base.1" && nums_tasks="$(( nums_tasks - ${#tasks_to_remove[@]} ))"
    }

    printf "\n"
  }

  local color_key="r"
  local percentage=$(( nums_tasks_done*100 / nums_tasks ))
  [ "$percentage" -eq 100 ] && color_key="g" ## se todas as tarefas foram concluídas

  # sed -i -E "0,/(done-)[0-9]+(.+)\([0-9]+(.+of...)[0-9]+\)/ s//\1${percentage}\2(${nums_tasks_done}\3${nums_tasks})/" "$PATH_TO_TASKS_FILE" \
  sed -i -E "0,/(done-)[0-9]+(.+)\([0-9]+(.+of...)[0-9]+\)/ s//\1${percentage}\2(${nums_tasks_done}\3${nums_tasks})/" "tests/texto_base.1" \
    && printf "${COLORS[w]}Now ${COLORS[$color_key]}${percentage}%% ${COLORS[w]}(${nums_tasks_done} of ${nums_tasks}) done!${COLORS[n]}\n"

  exit 0 ## para sair do loop (na função main) e fechar o programa
}

## Marca ou desmarca uma tarefa para remoção.
## Bind da tecla 'delete'.
bind_delete() {
  ## verificando se já está marcado para remoção
  [ -n "${tasks_to_remove[$curr_task_index]+_}" ] && remove_delete_mark || mark_delete_task
}

## Cria, se não existir, um diretório para a tarefa corrente.
## @use: mkdir
bind_d() {
  set_file_and_dir! "${list_tasks_not_done[$curr_task_index]#*:}"
  [ -n "$normalized_task_name" ] || return 1
  # dir="$CURR_DIR/$normalized_task_name"
  dir="./$normalized_task_name"

  if [ ! -d "$dir" ]; then
    mkdir -p "$dir" || return 1 ## ERROR
    emit_beep
  fi
  created_dirs[${list_tasks_not_done[$curr_task_index]%%:*}]="$dir"
}

## Cria um arquivo de texto para a tarefa corrente.
## @use: printf read touch
bind_f() {
  printf "\\e[?5h" ## turn on reverse video
  emit_beep ## avisa que está esperando uma entrada
  read -rs extension
  printf "\\e[?5l" ## turn on normal video

  ## remover caracteres inválidos (uso das setas, brancos, etc)
  local extension="${extension//[[:cntrl:]]\[[[:alnum:]][[:punct:]]/}"
  extension="${extension//[[:cntrl:]]\[[[:alnum:]]/}"
  extension="${extension//[[:blank:]]/}"
  extension="${extension#.}" ## remover o ponto se iniciar na 'extension'

  if [ -n "$extension" ]; then
    set_file_and_dir! "${list_tasks_not_done[$curr_task_index]#*:}" "$extension"
    touch "$file" || return 1 ## ERROR
    emit_beep
  fi
  created_files[${list_tasks_not_done[$curr_task_index]%%:*}]="$file"
}

## Abre o link da tarefa corrente.
## @use: sed open/cygstart
bind_o() {
  [ -n "$OPEN" ] || return 1

  local curr_task_line=${list_tasks_not_done[$curr_task_index]%%:*}
  # local task_title=$(sed -rn "$curr_task_line s/(http[^\)]+).+$/\1/p" "$PATH_TO_TASKS_FILE")
  local task_title=$(sed -rn "$curr_task_line s/(http[^\)]+).+$/\1/p" tests/texto_base.1)
  local link_without_http="${task_title#*\(http}"

  if [ -n "$link_without_http" ]; then
    emit_beep
    $OPEN "http$link_without_http"
  fi
}


# ====================================================== #
# ==================== specific ======================== #
# ====================================================== #

## Mostra o indicador de navegação.
## @args: [quantidade de linhas extras ocupadas pelo nome da tarefa]
## @use: printf
print_navi() {
  move_to_navi ${1}
  printf "%s${NAVI_SYMBOL}%s" ${NAVI_COLOR} ${COLORS[n]}
  # move_to_column $column_sep ## desnecessário se o cursor estiver escondido
}

## Apaga o indicador de navegação e posiciona o cursor para sua coluna.
## @use: printf
erase_navi() {
  move_to_navi
  printf "\\e[${NAVI_LENGTH}X" ## escreve N brancos à direita
  # printf "\\e[1P" ## apaga caractere à direita
  move_to_navi
}

## Move o cursor para o indicador de navegação.
## @args: [quantidade de linhas extras ocupadas pelo nome da tarefa]
move_to_navi() {
  [ "${1:-0}" -gt 0 ] && move_up_lines $1
  move_to_column $NAVI_COLUMN
}

## Marca a tarefa, que está sobre o cursor, como "concluída".
## @use: printf
mark_done_task() {
  [ -n "${tasks_done[$curr_task_index]+_}" ] && return ## verificando presença no array associativo
  tasks_done[$curr_task_index]="${list_tasks_not_done[$curr_task_index]%%:*}" ## associando o index com a linha real
  unset tasks_to_remove[$curr_task_index] ## sobrescrevendo a ação 'remover tarefa'

  move_to_navi

  local curr_task="${list_tasks_not_done[$curr_task_index]#*:}"
  printf "%s%*d$SEPARATOR %s$curr_task%s" ${COLORS[g]} $offset $(( curr_task_index + 1 )) ${COLORS[gr]} ${COLORS[n]}

  local line_width=$(( offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( line_width / screen_width )) ## quantas linhas a mais o title está ocupando

  print_navi $voffset
}

## Remove a marca "concluída" da tarefa que está sobre o cursor.
## @use: printf
remove_done_mark() {
  [ -n "${tasks_done[$curr_task_index]+_}" ] || return ## verificando presença no array associativo
  unset tasks_done[$curr_task_index] ## removendo do array associativo

  move_to_navi

  local curr_task="${list_tasks_not_done[$curr_task_index]#*:}"
  printf "%s%*d$SEPARATOR $curr_task%s" ${COLORS[n]} $offset $(( curr_task_index + 1 )) ${COLORS[n]}

  local line_width=$(( offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( line_width / screen_width )) ## quantas linhas a mais o title está ocupando

  print_navi $voffset
}

## Marca a tarefa, que está sobre o cursor, como "remover".
## @use: printf
mark_delete_task() {
  tasks_to_remove[$curr_task_index]="${list_tasks_not_done[$curr_task_index]%%:*}" ## associando o index com a linha real
  unset tasks_done[$curr_task_index] ## sobrescrevendo a ação 'marcar como feita'

  move_to_navi

  local curr_task="${list_tasks_not_done[$curr_task_index]#*:}"
  printf "%s%*d$SEPARATOR %s$curr_task%s" ${COLORS[r]} $offset $(( curr_task_index + 1 )) ${COLORS[gr]} ${COLORS[n]}

  local line_width=$(( $offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( $line_width / $screen_width )) ## quantas linhas a mais o title está ocupando

  print_navi $voffset
}

## Remove a marca "remover" da tarefa que está sobre o cursor.
## @use: printf
remove_delete_mark() {
  unset tasks_to_remove[$curr_task_index] ## removendo do array associativo

  move_to_navi

  local curr_task="${list_tasks_not_done[$curr_task_index]#*:}"
  printf "%s%*d$SEPARATOR $curr_task%s" ${COLORS[n]} $offset $(( curr_task_index + 1 )) ${COLORS[n]}

  local line_width=$(( offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( line_width / screen_width )) ## quantas linhas a mais o title está ocupando

  print_navi $voffset
}

## Se possível, vai para próxima tarefa (linha abaixo).
## @use: printf
next_task() {
  [ $(( curr_task_index + 1 )) -lt $nums_tasks_not_done ] || return
  erase_navi

  local curr_task="${list_tasks_not_done[$curr_task_index]}"
  local line_width=$(( offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( line_width / screen_width ))
  ((curr_task_index++))

  move_down_lines $(( voffset + 1 ))
  print_navi
}

## Se possível, vai para a tarefa anterior (linha acima).
## @use: printf
previous_task() {
  [ $curr_task_index -ne 0 ] || return
  erase_navi

  ((curr_task_index--))
  local curr_task="${list_tasks_not_done[$curr_task_index]}"
  local line_width=$(( offset + ${#curr_task_index} + ${#SEPARATOR} + ${#curr_task} ))
  local voffset=$(( line_width / screen_width ))

  move_up_lines $(( voffset + 1 ))
  print_navi
}


# ===================================================== #
# ==================== generic ======================== #
# @use: printf read tput                                #
# ===================================================== #

move_to_sof() {
  printf "\\e[${SOF_CURSOR_POS:-1}f"
}

move_to_eof() {
  [ -n "$NOT_MINGW_TERM" ] || return 1 ## ERROR (não compatível com o MinGW)
  printf "\\e[${eof_cursor_pos%;*};1f"
}

erase_to_eol() {
  printf "\\e[K"
}

update_eof_cursor_pos!() {
  [ -n "$NOT_MINGW_TERM" ] || return 1 ## ERROR (não compatível com o MinGW)
  printf "\\e[6n" ## no MinGW não funciona como o esperado
  read -sdR eof_cursor_pos
  eof_cursor_pos="${eof_cursor_pos#*[}"
}

emit_beep() {
  printf "\007"
}

hide_cursor() {
  printf "\\e[?25l"
}

show_cursor() {
  printf "\\e[?25h"
}

clear_screen_exit() {
  ## limpar até o fim da tela (representando a "parada" do programa) e ativa o vídeo normal
  printf "\n\\e[0J\\e[?5l"
  show_cursor
  exit 0
}

save_cursor() {
  printf "\\e[s"
}

restore_cursor() {
  printf "\\e[u"
}

move_to_column() {
  printf "\\e[%dG" $((${1:-0}))
}

move_up_lines() {
  local lines=${1:-0}
  printf "\\e[%dA" $lines
}

move_down_lines() {
  local lines=${1:-0}
  printf "\\e[%dB" $lines
}

update_screen_width!() {
  screen_width=$(tput cols)
}


####
main
####
