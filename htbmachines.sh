#!/bin/bash

# Enable strict mode and enhanced error handling
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

# Command-line argument variables
os_optarg=""
difficulty_optarg=""

# Function to handle and display error information. Prints the error line, command, and call stack.
#
# Parameters:
#   $1 - The line number where the error occurred.
#   $2 - The command that caused the error.
#
handleError() {
    echo -e "\n${RED}[!]Error on line: $1  command:$2${ENDCOLOR}\n" >&2

    echo -e "\nDisplaying the ERROR call stack:\n"
    for((i=0; i<${#FUNCNAME[@]}; i++)); do
        echo -e "\n(Level[$i])  Line: ${BASH_LINENO[$i]} Function: ${FUNCNAME[$i]}"
    done

    exit 1
}

# Sets up an error trap to catch and handle any errors during script execution
trap 'handleError $LINENO $BASH_COMMAND' ERR


# Description: Displays the options menu.
#
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

# Description: A function that downloads a file.
#
# Global variables:
#   $file - bundle.js
#   $old_file - bundle.js.old
# Returns:
#   0 - Success: files downloaded.
#   1 - Error: some operation fails.
#
download_files() {
    url="https://htbmachines.github.io/bundle.js" 

    if ! curl -s -o "${file}" "${url}" &>/dev/null; then
        rm -f "${file}";
        echo -e "\n${RED}[!]Error: download failed${ENDCOLOR}"
        return 1
    fi

    echo -e "\n${WHITE}[+][+][+]  Files downloaded!!!  [+][+][+]${ENDCOLOR}\n"
    js-beautify "${file}" | sponge "${file}"
    return 0
}

# Description: A function that calculates the hash of the new and old versions of bundle.js to compare them and
#            update if necessary. It prints the hash of these files to stdout as well.
#
# Global variables:
#   $file - bundle.js
#   $old_file - bundle.js.old
# Example:
#   ./script.sh -u
# Returns:
#   0 - Success: files updated or already up to date.
#   1 - Error: some operation fails.
#
update_files() {
    local hash=""
    local old_hash=""

    hash="$(md5sum "${file}" | awk '{print $1}')"
    old_hash="$(md5sum "${old_file}" | awk '{print $1}')"

    echo -e "\n${MAGENTA}New File Hash:${ENDCOLOR} ${hash}"
    echo -e "\n${MAGENTA}Old File Hash:${ENDCOLOR} ${old_hash}"

    if [ "${old_hash}" != "${hash}" ]; then
        echo -e "\n${WHITE}[+][+][+]  Files has been updated  [+][+][+]${ENDCOLOR}\n"
        rm -f "${old_file}" || return 1
        return 0
    else
        echo -e "\n${CYAN}[+][+][+]  Files are already up to date  [+][+][+]${ENDCOLOR}\n"
        rm -f "${old_file}" || return 1
        return 0
    fi

    return 1
}

# Description: 
#   Checks if the file bundle.js exists. If not, attempts to download it. If it exists, tries to rename it, downloads a new version of the same file,
#   and checks if it is updated to update it if necessary.
#
# Example:
#   ./script.sh -n Jewel
# Returns:
#   0 - Success: The operation of downloading, renaming, or updating the file was successful. Note that these operations can be successful separately
#               but are executed sequentially. If renaming (mv) fails, subsequent operations will not be performed. If renaming succeeds, the following 
#               operations may or may not succeed individually or collectively.
#   1 - Error: An error occurred during any of these operations.
#
check_files() {
    if [ ! -f bundle.js ]; then
        download_files || return 1
    else
        mv "${file}" "${old_file}" || return 1
        download_files || return 1
        update_files || return 1
    fi
}

# Description: Searches for a machine name based on the '-n' option followed by a valid machine name.
#
# Parameter:
#   $1 - The value of the '-n' option (machine name).
# Example:
#   ./script.sh -n Jewel
# Returns:
#   0 - Success: Prints the results.
#   1 - Error: Prints a message indicating no results.
#
search_name() {
    local name="$1"
    local find_name=""
    find_name="$(grep -i "name: \"$name\"" -A 10 bundle.js | grep -vE 'id:|sku:|like:|resuelta:|activeDirectory:|bufferOverFlow:|lf.push' | sed 's/^[ \t]*//' | fmt -t | awk '{print "\t" $0}' | sed '/,$/s/,$//')"

    if [ ! "${find_name}" ]; then
        echo -e "\n\t${RED}[!][!][!]  Machine name${ENDCOLOR} \"$name\" ${RED}doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        return 1
    fi

    echo -e "\n${find_name}\n"
    return 0
}

# Description: Searches for an IP address based on the '-i' option followed by a valid IP address in the format (255.255.255.255).
#
# Parameter:
#   $1 - The value of the '-i' option (IP address).
# Example:
#   ./script.sh -i 10.10.10.29
# Returns:
#   0 - Success: Prints the result.
#   1 - Error: Prints a message indicating an invalid address or no result.
#
search_ip() {
    local ip="$1"
    local ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"

    if ! echo $ip | grep -Eq "$ip_regex"; then
        echo -e "\n${RED}[!][!][!]  The IP address${ENDCOLOR} $ip ${RED}is not valid. Insert an address in a format such as${ENDCOLOR} 255.255.255.255 ${RED}[!][!][!]${ENDCOLOR}\n"
        return 1
    fi

    local find_ip=""

    find_ip="$(grep "ip: \"${ip}\"" -B 3 bundle.js | grep -vE 'ip:|id:|sku:|lf.push|!0' | awk '{print $2}' | tr '",' ' ' | sed 's/^ //')"
    local find_ip_return_code=$?

    if [ $find_ip_return_code -ne 0 ]; then
        echo -e "\n\t${RED}[!][!][!]  IP${ENDCOLOR} \"${ip}\" ${RED}doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        print_help_menu
        return 1
    fi

    echo -e "\n${BLUE}The machine with IP $ip is:${ENDCOLOR} ${find_ip}\n"
    return 0
}

# Description: Searches for Operating System based on the '-o' option followed by an operating system name.
#
# Parameter:
#   $1 - The value of the '-o' option (operating system name).
# Example:
#   ./script.sh -o Linux
# Returns:
#   0 - Success: Prints the results.
#   1 - Error: Prints a message indicating no results.
#
search_os() {
    local os="$1"
    local find_os=""
    find_os="$(grep -i "so: \"$os\"" -B 4 bundle.js | grep -vE 'id:|sku:|ip:|so:|resuelta:|lf.push' | awk '{print $2}' | tr ',"--' ' ' | sort | column -c "$(tput cols)" -x)"

    if [ -z "${find_os}" ]; then
        echo -e "\n\t${RED}[!][!][!]  OS${ENDCOLOR} \"${os}\"${RED} doesn´t exists in the database  [!][!][!]${ENDCOLOR}\n" >&2
        return 1
    fi

    echo -e "\n${BLUE}Displaying results for OS${ENDCOLOR} (${os^})\n\n${find_os}\n"
    return 0
}

# Description: Searches for difficulty based on the '-d' option followed by a difficulty level.
#
# Parameter:
#   $1 - The value of the -d option (Difficulty).
#         Difficulty values should be written in Spanish with accents where applicable:
#         - fácil (easy)
#         - medio (medium)
#         - difícil (hard)
#         - insane (same)
# Example:
#   ./script.sh -d fácil
# Returns:
#   0 - Success: Prints the results.
#   1 - Error: Prints a message indicating no results.
#
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

# Description: Searches for skills based on the '-s' option followed by a valid skill name.
#
# Parameter:
#   $1 - The value of the -s option (skill name).
#         If the skill name consists of multiple words (e.g., "Remote Code Execution"),
#         it should be enclosed in quotes. For single words, quotes are optional.
# Example:
#   ./script.sh -s "Python"
#   ./script.sh -s "Remote Code Execution"
# Returns:
#   0 - Success: Prints the results.
#   1 - Error: Prints a message indicating no results.
#
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

# Description: Searches for the YouTube link based on the '-y' option followed by a valid machine name.
#
# Parameter:
#   $1 - The value of the -y option (YouTube link).
# Example:
#   ./script.sh -y Bounty
# Returns:
#   0 - Success: Prints the result.
#   1 - Error: Prints a message indicating no result.
#
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

# Description: Searches for results based on the combined options '-o' (Operating System) and '-d' (Difficulty).
#
# Parameters:
#   $1 - The value of the -o option (Operating System).
#   $2 - The value of the -d option (Difficulty).
#         Difficulty values should be written in Spanish with accents where applicable:
#         - fácil (easy)
#         - medio (medium)
#         - difícil (hard)
#         - insane (same)
# Example:
#   ./script.sh -o Windows -d fácil
# Returns:
#   0 - Success: Prints the results.
#   1 - Error: Prints a message indicating no results.
#
search_os_difficulty() {
    local os="$1"
    local difficulty="$2"
    local find_os_difficulty=""

    search_os "$os" &>/dev/null
    local os_return_code=$?

    search_difficulty "$difficulty" &>/dev/null
    local difficulty_return_code=$?

    if [ "$os_return_code" -eq 0 ] && [ "$difficulty_return_code" -eq 0 ]; then
        find_os_difficulty="$(grep -i "so: \"$os\"" -C 5 bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk '{print $2}' | tr '",' ' ' | sort | column -c "$(tput cols)" -x)"
        echo -e "\n${BLUE}[+][+][+]Machines with OS${ENDCOLOR} ${os^} ${BLUE}and difficulty${ENDCOLOR} ${difficulty^}${BLUE}[+][+][+]${ENDCOLOR}"
        echo -e "\n$find_os_difficulty\n"
        return 0
    else
        echo -e "\n\t${RED}[!][!][!] There are no matches for OS${ENDCOLOR} ${os} ${RED}and difficulty${ENDCOLOR} $difficulty ${RED}[!][!][!]${ENDCOLOR}\n" >&2
        return 1
    fi
}

# Description: Controls the logic when -d and -o options are selected, individually or combined.
#
# Global variables:
#   $os_optarg: -o option arguments
#   $difficulty_optarg: -d option arguments
#
# Return:
#   0 - Success: matches found
#   1 - Error : no matches found or invalid arguments
#
search_combined_options() {

    # Options -o and -d selected
    if [ -n "$os_optarg" ] && [ -n "$difficulty_optarg" ]; then

        search_os_difficulty "$os_optarg" "$difficulty_optarg" || { print_help_menu; return 1;}

    # Option -o selected
    elif [ -n "$os_optarg" ] && [ -z "$difficulty_optarg" ]; then

        search_os "$os_optarg" || { print_help_menu; return 1; }

    # Option -d selected
    elif [ -n "$difficulty_optarg" ] && [ -z "$os_optarg" ]; then

        search_difficulty "$difficulty_optarg" || { print_help_menu; return 1; }

    else
        return 1
    fi
}

# Description: Check if an option has exactly one argument. If the option has more than one is considered an error,
#
# Parameters:
#   $1 - Option selected (e.g., -n).
#   $2 - Length of arguments provided for the option.
#   #
# Return:
#   0 - Success: the option has exactly one argument.
#   1 - Error: the option has more than one argument (not allowed).
#
check_options() {
    option=$1
    check_args=$(($2-1))

    if [ "$check_args" -gt 1 ]; then
        echo -e "\n\t${MAGENTA}Option${ENDCOLOR} -$option ${MAGENTA}allows only one argument${ENDCOLOR}"
        return 1
    fi

    return 0
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
            ;;
        i)
            if ! check_options "$opt" $#; then
                print_help_menu
                exit 1
            fi

            # comprobar formato direccion ip
            search_ip "$OPTARG" || exit 1
            ;;
        o)
            os_optarg="$OPTARG"
            ;;
        d)
            difficulty_optarg="$OPTARG"
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

# Check if no options were entered
if [ $OPTIND -eq 1 ]; then
    echo -e "\n${BLUE}[!][!][!]  You must enter an option  [!][!][!]${ENDCOLOR}\n" >&2
    print_help_menu
    exit 1
fi

# Options -o and -d or -d and -o combined
search_combined_options || exit 1

# Move the index to process the remaining arguments safely with $1, $n, etc.
shift $((OPTIND-1))

# Handle unknown arguments. At this point $1, $n are arguments that have not been procesed.
if [ $# -gt 0 ]; then
    echo -e "\n${RED}[!][!][!]  Unexpected arguments: $*  [!][!][!]${ENDCOLOR}\n" >&2
fi

unset $file $old_file "$os_optarg" "$difficulty_optarg"
