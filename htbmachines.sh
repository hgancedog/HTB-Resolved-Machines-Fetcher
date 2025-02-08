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

# Control variables
check_os=1
check_difficulty=1

# search_os & search_difficulty $OPTARG
os_optarg=""
difficulty_optarg=""

handleError() {
    echo -e "\n${RED}[!]Error on line: $1  command:$2${ENDCOLOR}\n" >&2
    exit 1
}

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
    name="$1"
    find_machine="$(grep -i "name: \"$name\"" -A 10 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|activeDirectory:|bufferOverFlow:|lf.push' | sed 's/^[ \t]*//' | fmt -t | awk '{print "\t" $0}' | sed '/,$/s/,$//')"

    if [ ! "${find_machine}" ]; then
        echo -e "\n\t${RED}[!][!][!]  Machine name${ENDCOLOR} \"$name\" ${RED}doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        exit 1
    fi

    echo -e "\n${find_machine}\n"
    return 0
}

search_ip() {
    ip="$1"
    find_ip="$(grep "ip: \"${ip}\"" -B 3 bundle.js | grep -vE 'ip:|id:|sku:' | awk '{print $2}' | tr '",' ' ' | sed 's/^ //')"

    if [ ! "${find_ip}" ]; then
        echo -e "\n\t${RED}[!][!][!]  IP${ENDCOLOR} \"${ip}\" ${RED}doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        exit 1
    fi

    echo -e "\n${BLUE}The machine with IP $ip is:${ENDCOLOR} ${find_ip}\n"
    return 0
}

search_os() {
    os="$1"
    find_os="$(grep -i "so: \"$os\"" -B 4 bundle.js | grep -vE 'id:|sku:|ip:|so:|resuelta:|lf.push' | awk '{print $2}' | tr ',"--' ' ' | sort | column -c "$(tput cols)" -x)"

    if [ ! "${find_os}" ]; then
        echo -e "\n\t${RED}[!][!][!]  OS${ENDCOLOR} \"${os}\"${RED} doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        exit 1
    fi

    echo -e "\n${BLUE}Displaying results for OS${ENDCOLOR} (${os^})\n\n${find_os}\n"
    return 0
}

search_difficulty() {
    difficulty="$1"
    find_difficulty="$(grep -i "dificultad: \"$difficulty\"" -B 5 bundle.js | grep -vE 'id:|sku:|ip:|so:|resuelta:|lf.push|dificultad:' | awk '{print $2}' | tr '",' ' ' | sort | column -c "$(tput cols)" -x)"

    if [ ! "${find_difficulty}" ]; then
        echo -e "\n\t${RED}[!][!][!]  There are no machines of${ENDCOLOR} \"$difficulty\" difficulty  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        exit 1
    fi

    echo -e "\n${BLUE}Displaying results for difficulty${ENDCOLOR} (${difficulty^})\n\n${find_difficulty}\n"
    return 0
}

search_skill() {
    skill="$1"
    find_skill="$(grep -i "skills: " -B 6 bundle.js | grep -i "$skill" -B 6 | grep 'name:' | awk '{print $2}' | tr '",' ' ' | sort | column -c "$(tput cols)" -x)"


    if [ ! "${find_skill}" ]; then
        echo -e "\n\t${RED}[!][!][!]  Skill${ENDCOLOR} \"$skill\" ${RED}not found in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        exit 1
    fi

    echo -e "\n${BLUE}Displaying results for skill${ENDCOLOR} (${skill^})\n\n${find_skill}\n"
    return 0
}

search_link() {
    name="$1" 
    find_link="$(grep -i "name: \"$name\"" -A 10 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|activeDirectory:|bufferOverFlow:|lf.push' | sed 's/^[ \t]*//' | grep 'youtube:' | sed '/,$/s/,$//' | tr '"' ' ' | awk '{print $2}')"

    if [ ! "${find_link}" ]; then
        echo -e "\n\t${RED}[!][!][!]  Machine ${name} doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        exit 1
    fi

    echo -e "\n${BLUE}The resolution for the machine${ENDCOLOR} ${name^} ${BLUE}is in the following link:${ENDCOLOR} ${find_link}\n"
    return 0
}

search_combined_options() {
    if [ $check_os -eq 0 ] && [ $check_difficulty -eq 0 ]; then
        echo -e "\nProbando uso combinado"

    elif [ $check_os -eq 0 ] && [ $check_difficulty -eq 1 ]; then    
        if ! search_os "$os_optarg"; then
            exit 1
        fi

    elif [ $check_difficulty -eq 0 ] && [ $check_os -eq 1 ]; then
        if  ! search_difficulty "$difficulty_optarg"; then
            exit 1
        fi
    fi
}

OPTIND=1;
while getopts ":hun:i:o:d:s:y:" opt; do
    case ${opt} in
        h)
            print_help_menu

            if [ $OPTIND -gt 2 ] ; then
                echo -e "\n${MAGENTA}[!][!][!]  Unexpected arguments: ${!OPTIND} in option -${opt} [!][!][!]${ENDCOLOR}\n" >&2
                shift $((OPTIND-1))
            fi
            ;;
        u)
            check_files
            ;;
        n)
            search_name "$OPTARG"
            ;;
        i)
            search_ip "$OPTARG"
            ;;
        o)
            check_os=0
            os_optarg="$OPTARG"
            ;;
        d)
            check_difficulty=0
            difficulty_optarg="$OPTARG"
            ;;
        s)
            search_skill "$OPTARG"
            ;;
        y)
            search_link "$OPTARG"
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

# Options -o and -d or -d and -o combined
search_combined_options

# to handle arguments safely with $1, $n, etc.
shift $((OPTIND-1))

if [ $OPTIND -eq 1 ]; then
    echo -e "\n${BLUE}[!][!][!]  You must enter an option  [!][!][!]${ENDCOLOR}\n" >&2
    print_help_menu
fi


# function for handling unknown arguments. At this point $1, $n are arguments
if [ $# -ge 1 ]; then
    echo -e "\n${RED}[!][!][!]  Unexpected arguments: $*  [!][!][!]${ENDCOLOR}\n" >&2
fi

unset $file $old_file $check_os $check_difficulty "$os_optarg" "$difficulty_optarg"
