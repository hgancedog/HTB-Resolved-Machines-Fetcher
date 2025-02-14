#!/bin/bash

# Activate only for error debugging purposes
set -eEuo pipefail
#
#Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
GRAY='\e[0;37m'
ENDCOLOR='\033[0m'

# File-related variables
file="bundle.js"
old_file="bundle.js.old"

os_optarg=""
difficulty_optarg=""

# For error tracking purposes
print_call_stack() {
    local frame=0

    while caller $frame &>/dev/null; do
        echo -e "\nLevel $frame:  (Function=> ${FUNCNAME[$frame]}) (Line=> $(caller $frame | awk '{print $1}'))\n"
        ((frame++))
    done
}


# For error tracking
handleError() {
    echo -e "\n${RED}[!]Error on line: $1  command:$2${ENDCOLOR}\n" >&2
    print_call_stack
    exit 1
}

# Enable only for debugging
trap 'handleError $LINENO $BASH_COMMAND' ERR

print_help_menu() {
    echo -e "\n\t${YELLOW}[+]${ENDCOLOR}${GRAY} Please, select an option:"
    echo -e "\t\tu) Dowload Or Update Files"
    echo -e "\t\tn) Search By Machine Name"
    echo -e "\t\ti) Search By IP address"
    echo -e "\t\to) Search By Operating System"
    echo -e "\t\td) Search By Difficulty"
    echo -e "\t\ts) Search By Skill"
    echo -e "\t\ty) Get Youtube Link"
    echo -e "\t\th) Display This Help Panel${ENDCOLOR}"
    echo -e "\n"
    return 0
}

download_files() {
    url="https://htbmachines.github.io/bundle.js" 

    if ! curl -s -o "${file}" "${url}" &>/dev/null; then
        rm -f "${file}";
        echo -e "\n${RED}[!]Error: download failed${ENDCOLOR}"
        return 1
    fi

    js-beautify "${file}" | sponge "${file}"
    return 0
}

update_files() {
    local hash=""
    local old_hash=""

    hash="$(md5sum "${file}" | awk '{print $1}')"
    old_hash="$(md5sum "${old_file}" | awk '{print $1}')"

    echo -e "\n${MAGENTA}New File Hash:${ENDCOLOR} ${hash}"
    echo -e "\n${MAGENTA}Old File Hash:${ENDCOLOR} ${old_hash}"

    if [ "${old_hash}" != "${hash}" ]; then
        echo -e "\n${WHITE}[+][+][+]  Files has been updated  [+][+][+]${ENDCOLOR}\n"
        rm -f "${old_file}"
    else
        echo -e "\n${CYAN}[+][+][+]  Files are already up to date  [+][+][+]${ENDCOLOR}\n"
        rm -f "${old_file}"
    fi

    return 0
}

check_files() {
    if [ ! -f bundle.js ]; then
        download_files
        echo -e "\n${WHITE}[+][+][+]  Files downloaded!!!  [+][+][+]${ENDCOLOR}\n"
    else
        mv "${file}" "${old_file}"
        download_files
        update_files
    fi
    return 0
}

search_name() {
    local name="$1"
    local find_name=""
    find_name="$(grep -i "name: \"$name\"" -A 10 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|activeDirectory:|bufferOverFlow:|lf.push' | sed 's/^[ \t]*//' | fmt -t | awk '{print "\t" $0}' | sed '/,$/s/,$//')"

    if [ -z "${find_name}" ]; then
        echo -e "\n\t${RED}[!][!][!]  Machine name${ENDCOLOR} \"$name\" ${RED}doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2 2>/dev/null
        return 1
    fi

    echo -e "\n${find_name}\n"
    return 0
}

search_ip() {
    local ip="$1"
    local find_ip=""
    find_ip="$(grep "ip: \"${ip}\"" -B 3 bundle.js | grep -vE 'ip:|id:|sku:|lf.push|!0' | awk '{print $2}' | tr '",' ' ' | sed 's/^ //')"

    if [ -z "${find_ip}" ]; then
        echo -e "\n\t${RED}[!][!][!]  IP${ENDCOLOR} \"${ip}\" ${RED}doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        return 1
    fi

    echo -e "\n${BLUE}The machine with IP $ip is:${ENDCOLOR} ${find_ip}\n"
    return 0
}

search_os() {
    local os="$1"
    local suppress_help_menu="$2"
    local find_os=""
    find_os="$(grep -i "so: \"$os\"" -B 4 bundle.js | grep -vE 'id:|sku:|ip:|so:|resuelta:|lf.push' | awk '{print $2}' | tr ',"--' ' ' | sort | column -c "$(tput cols)" -x)"

    if [ -z "${find_os}" ]; then
        echo -e "\n\t${RED}[!][!][!]  OS${ENDCOLOR} \"${os}\"${RED} doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        return 1
    fi

    echo -e "\n${BLUE}Displaying results for OS${ENDCOLOR} (${os^})\n\n${find_os}\n"
    return 0
}

search_difficulty() {
    local difficulty="$1"
    local find_difficulty=""

    find_difficulty="$(grep -i "dificultad: \"$difficulty\"" -B 5 bundle.js | grep -vE 'id:|sku:|ip:|so:|resuelta:|lf.push|dificultad:' | awk '{print $2}' | tr '",' ' ' | sort | column -c "$(tput cols)" -x)"

    if [ -z "${find_difficulty}" ]; then
        echo -e "\n\t${RED}[!][!][!]  There are no machines of${ENDCOLOR} \"$difficulty\" ${RED}difficulty  [!][!][!]${ENDCOLOR}\n" >&2
        return 1
    fi

    echo -e "\n${BLUE}Displaying results for difficulty${ENDCOLOR} (${difficulty^})\n\n${find_difficulty}\n"
    return 0
}

search_skill() {
    local skill="$1"
    local find_skill=""
    find_skill="$(grep -i "skills: " -B 6 bundle.js | grep -i "$skill" -B 6 | grep 'name:'  | awk '{print $2}' | tr '",' ' ' | sort | column -c "$(tput cols)" -x)"

    if [ -z "${find_skill}" ]; then
        echo -e "\n\t${RED}[!][!][!]  Skill${ENDCOLOR} \"$skill\" ${RED}not found in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        return 1
    fi

    echo -e "\n${BLUE}Displaying results for skill${ENDCOLOR} (${skill^})\n\n${find_skill}\n"
    return 0
}

search_link() {
    local name="$1"
    local find_link=""
    find_link="$(grep -i "name: \"$name\"" -A 10 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|activeDirectory:|bufferOverFlow:|lf.push' | sed 's/^[ \t]*//' | grep 'youtube:' | sed '/,$/s/,$//' | tr '"' ' ' | awk '{print $2}')"

    if [ -z "${find_link}" ]; then
        echo -e "\n\t${RED}[!][!][!]  Machine ${name} doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        return 1
    fi

    echo -e "\n${BLUE}The resolution for the machine${ENDCOLOR} ${name^} ${BLUE}is in the following link:${ENDCOLOR} ${find_link}\n"
    return 0
}

search_os_difficulty() {
    local os="$1"
    local difficulty="$2"
    local os_return_code
    local difficulty_return_code

    local find_os_difficulty=""

    search_os "$os" &>/dev/null
    os_return_code=$?

    search_difficulty "$difficulty" &>/dev/null
    difficulty_return_code=$?

    if [ "$os_return_code" -eq 0 ] && [ "$difficulty_return_code" -eq 0 ]; then
        find_os_difficulty="$(grep -i "so: \"$os\"" -C 5 bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk '{print $2}' | tr '",' ' ' | sort | column -c "$(tput cols)" -x)"
        echo -e "\n${BLUE}[+][+][+]Machines with OS${ENDCOLOR} ${os^} ${BLUE}and difficulty${ENDCOLOR} ${difficulty^}${BLUE}[+][+][+]${ENDCOLOR}"
        echo -e "\n$find_os_difficulty\n"
        return 0
    else
        return 1
    fi

    # elif [ "$os_return_code" -eq 0 ] && [ "$difficulty_return_code" -eq 1 ] ; then
    #     search_os "$os"
    #     search_difficulty "$difficulty"
    #     print_help_menu
    #     return 1
    #
    # elif [ "$os_return_code" -eq 1 ] && [ "$difficulty_return_code" -eq 0 ]; then
    #     search_difficulty "$difficulty"
    #     search_os "$os"
    #     print_help_menu
    #     return 1
    #
    # else
    #     search_os "$os"
    #     search_difficulty "$difficulty"
    #     print_help_menu
    #     return 1
    #
    # fi
}

search_combined_options() {
    # Options -o & -d selected
    if [ -n "$os_optarg" ] && [ -n "$difficulty_optarg" ]; then

        search_os_difficulty "$os_optarg" "$difficulty_optarg" &>/dev/null
        os_difficulty_return_code=$?

        if [ $os_difficulty_return_code -ne 0 ]; then
            print_help_menu
                        return 1 
        fi

        search_os_difficulty "$os_optarg" "$difficulty_optarg"
        return 0

    # Option -o selected
    elif [ -n "$os_optarg" ] && [ -z "$difficulty_optarg" ]; then

        if  ! search_os "$os_optarg"; then
            print_help_menu
            return 1
        fi

        return 0

    # Option -d selected
    elif [ -n "$difficulty_optarg" ] && [ -z "$os_optarg" ]; then

        if  ! search_difficulty "$difficulty_optarg"; then
            print_help_menu
            return 1
        fi

        return 0

    else
        return 0
    fi
}


check_options() {

    option=$1
    check_args=$(($2-1))

    if [ "$check_args" -gt 1 ]; then
        echo -e "\n\t${MAGENTA}Option${ENDCOLOR} -$option ${MAGENTA}allows only one argument${ENDCOLOR}"
        return 1
    fi
}

OPTIND=1;
while getopts ":hun:i:o:d:s:y:" opt; do
    case ${opt} in
        h)
            print_help_menu

            if [ $# -ge 2 ] ; then
                shift
                echo -e "\n${MAGENTA}[!][!][!]  Unexpected arguments:${ENDCOLOR} $* ${MAGENTA}in option${ENDCOLOR} -${opt} ${MAGENTA}[!][!][!]${ENDCOLOR}\n" >&2
                exit 1
            fi

            exit 0
            ;;
        u)
            # comprobar si falla la descarga
            check_files
            ;;
        n)
            if ! check_options "$opt" $#; then 
                print_help_menu
                exit 1
            fi

            search_name "$OPTARG"
            exit 0
            ;;
        i)
            if ! check_options "$opt" $#; then
                print_help_menu
                exit 1
            fi

            # comprobar formato direccion ip
            search_ip "$OPTARG"   
            exit 0
            ;;
        o)
            os_optarg="$OPTARG"
            # os_length_args="$#"
            #
            # if ! search_combined_options "$os_optarg" "$os_length_args"; then
            #     return 1
            # fi
            ;;
        d)
            difficulty_optarg="$OPTARG"
            # difficulty_length_args="$#"
            # search_combined_options "$difficulty_optarg" "$difficulty_length_args"
            ;;
        s)
            if ! check_options "$opt" $#; then
                print_help_menu
                exit 1
            fi

            search_skill "$OPTARG"
            exit 0
            ;;
        y)
            if ! check_options "$opt" $#; then 
                print_help_menu
                exit 1
            fi

            search_link "$OPTARG"
            exit 0
            ;;
        :)
            echo -e "\n${RED}[!][!][!]  Option -${OPTARG} require an argument  [!][!][!]${ENDCOLOR}\n" >&2
            print_help_menu
            exit 1
            ;;
        \?)
            echo -e "${RED}\n[!][!][!]  Unknown option selected. Please choose a valid option  [!][!][!]\n${ENDCOLOR}" >&2
            print_help_menu
            exit 1
            ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    echo -e "\n${BLUE}[!][!][!]  You must enter an option  [!][!][!]${ENDCOLOR}\n" >&2
    print_help_menu
    exit 1
fi

# Options -o and -d or -d and -o combined
search_combined_options

# to handle arguments safely with $1, $n, etc.
shift $((OPTIND-1))

# COMPROBAR PUEDE NO SER NECESARIO YA QUE check_options() comprueba el numero de args, solo queda comprobar -o y -d combinadas
# function for handling unknown arguments. At this point $1, $n are arguments
if [ $# -gt 1 ]; then
    echo -e "\n${RED}[!][!][!]  Unexpected arguments: $*  [!][!][!]${ENDCOLOR}\n" >&2
fi

unset $file $old_file "$os_optarg" "$difficulty_optarg"
