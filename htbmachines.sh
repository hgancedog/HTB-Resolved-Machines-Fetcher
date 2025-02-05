#!/bin/bash

#Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
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

handleError() {
    echo -e "\n${RED}[!]Error on line: $1  command:$2${ENDCOLOR}\n" >&2
    exit 1
}

trap 'handleError $LINENO $BASH_COMMAND' ERR

print_help_menu() {
    echo -e "\n\t${YELLOW}[+]${ENDCOLOR}${GRAY} Please, select an option:"
    echo -e "\t\tu) Dowload Or Update Files"
    echo -e "\t\tm) Search By Machine Name"
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
    hash="$(md5sum "${file}" | awk '{print $1}')"
    old_hash="$(md5sum "${old_file}" | awk '{print $1}')"

    echo -e "\n${MAGENTA}New File Hash:${ENDCOLOR} ${hash}"
    echo -e "\n${MAGENTA}Old File Hash:${ENDCOLOR} ${old_hash}"

    if [ "${old_hash}" != "${hash}" ]; then
        echo -e "\n${WHITE}[+][+][+]  Files has been updated  [+][+][+]\n${ENDCOLOR}"
        rm -f "${old_file}"
    else
        echo -e "\n${CYAN}[+][+][+]  Files are already up to date  [+][+][+]\n${ENDCOLOR}"
        rm -f "${old_file}"
    fi

    return 0
}

check_files() {
    if [ ! -f bundle.js ]; then
        download_files
        echo -e "\n${WHITE}[+][+][+]  Files downloaded!!!  [+][+][+]\n${ENDCOLOR}"
    else
        mv "${file}" "${old_file}"
        download_files
        update_files
    fi
    return 0
}

search_machine_name() {
    machine_name="name: \"$1\""
    find_machine="$(grep -i "${machine_name}" -A 8 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|activeDirectory:|bufferOverFlow:' | sed 's/^[ \t]*//' | fmt -t | awk '{print "\t" $0}' | sed '/,$/s/,$//')"

    if [ ! "${find_machine}" ]; then
        echo -e "\n\t${RED}[!][!][!]  Machine $1 doesn´t exists in the database  [!][!][!]\n" >&2
        print_help_menu
    fi

    echo -e "\n${find_machine}\n"
    return 0
}

search_ip() {
    ip="ip: \"$1\""
    find_ip="$(grep "${ip}" -B 3 -A 7 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|--|\}\), lf\.push\(\{' | sed 's/^[ \t]*//' | sed '/,$/s/,$//'| fmt -t | awk '{print "\t" $0}')"

    if [ ! "${find_ip}" ]; then
        echo -e "\n\t${RED}[!][!][!]  IP $1 doesn´t exists in the database  [!][!][!]\n" >&2
        print_help_menu
    fi

    echo -e "\n${find_ip}\n"
    return 0
}

search_os() {
    os="so: \"$1\""
    find_os="$(grep -i "${os}" -B 4 -A 5 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|activeDirectory:|bufferOverFlow:|\}\), lf\.push\(\{' | sed 's/^[ \t]*//' | sed '/,$/s/,$//' | fmt -t | awk '{print "\t" $0}')"

    if [ ! "${find_os}" ]; then
        echo -e "\n\t${RED}[!][!][!]  OS $1 doesn´t exists in the database  [!][!][!]\n" >&2
        print_help_menu
    fi

    echo -e "\n${find_os}\n"
    return 0
}

search_difficulty() {
    difficulty="dificultad: \"$1\""
    find_difficulty="$(grep -i "${difficulty}" -B 5 -A 5 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|activeDirectory:|bufferOverFlow:|\}\), lf\.push\(\{' | sed 's/^[ \t]*//' | sed '/,$/s/,$//' | fmt -t | awk '{print "\t" $0}')"

    if [ ! "${find_difficulty}" ]; then
        echo -e "\n\t${RED}[!][!][!]  There are no machines of $1 difficulty  [!][!][!]\n" >&2
        print_help_menu
    fi

    echo -e "\n${find_difficulty}\n"
    return 0
}

search_skill() {
    skill="$1"
    echo -e "\n probando search_skill ${skill}"
}

OPTIND=1;
while getopts ":hum:i:o:d:s:" opt; do
    case ${opt} in
        h)
            print_help_menu

            if [ $OPTIND -ge 2 ] ; then
                echo -e "\n    Otra forma de imprimir argumentos no esperados: ${!OPTIND}"
                shift $((OPTIND-1))
                echo -e "\n${MAGENTA}[!][!][!]  Unexpected arguments: $* in option -${opt} [!][!][!]${ENDCOLOR}\n" >&2
            fi
            ;;
        u)
            check_files
            ;;
        m)
            search_machine_name "$OPTARG"
            ;;
        i)
            search_ip "$OPTARG"
            ;;
        o)
            search_os "$OPTARG"

            ;;
        d)
            search_difficulty "$OPTARG"
            ;;
        s)
            search_skill "$OPTARG"
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

if [ $OPTIND -le 1 ]; then
    echo -e "\n${BLUE}[!][!][!]  You must enter an option  [!][!][!]${ENDCOLOR}\n" >&2
    print_help_menu
fi

# to handle arguments safely with $1, $n, etc.
shift $((OPTIND-1))

# function for handling unknown arguments. At this point $1, $n are arguments
if [ $# -ge 1 ]; then
    echo -e "\n${RED}[!][!][!]  Unexpected arguments: $*  [!][!][!]${ENDCOLOR}\n" >&2
fi

unset $file $old_file
