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
    echo -e "\n\t${YELLOW}[+]${ENDCOLOR}${GRAY} Uso:"
    echo -e "\t\th) Display this help panel"
    echo -e "\t\tu) Dowload or update files"
 
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

    echo -e "\n${hash}"
    echo -e "\n${old_hash}"

    if [ "${old_hash}" != "${hash}" ]; then
        echo -e "\n${BLUE}[-]Files has been uptdated[-]\n${ENDCOLOR}"
        rm -f "${old_file}"
    else
        echo -e "\n${BLUE}[-]Files are already up to date[-]\n${ENDCOLOR}"
        rm -f "${old_file}"
    fi

    return 0
}

check_files() {
    if [ ! -f bundle.js ]; then
        download_files
        echo -e "\nFiles downloaded!!!"
    else
        mv "${file}" "${old_file}"
        download_files
        update_files
    fi
    return 0
}

OPTIND=1;
while getopts "hu" opt; do
    case ${opt} in
        h)
            print_help_menu
            ;;
        u)
            check_files
            ;;
       # h)
        #    print_help_menu
         #   ;;

        \?)
            echo -e "${RED}\n[!][!][!]Unknown option selected. Please choose a valid option[!][!][!]\n${ENDCOLOR}" >&2;
            ;;
    esac
done  
#to handle arguments safely with $1, $n, etc.
shift $((OPTIND-1))

unset $file $old_file
