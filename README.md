# HTB-Resolved-Machines-Fetcher
An interactive bash script for fetching and managing data of resolved HackTheBox machines, inspired by S4vitar, a Spanish professional cybersecurity specialist. It maintains original menu options for coherence but features unique and original programming logic.

## Features
- Download/Update Necessary Files
- Search by Machine Name
- Search by IP Address
- Search by Difficulty
- Search by Operating System
- Search by Skill
- Show YouTube Resolution Link
- Help Panel

## Requirements
- Bash shell
- curl (for downloading files)
- grep, sed, awk (for text processing)

## Getting Started
1. Clone the repository

2. Make the script executable:
chmod +x htbmachines.sh

3. Run the script to download the initial data:
./htbmachines.sh -u

Note: The repository includes a copy of bundle.js in case the download fails. Users can edit, remove, or add content to the bundle.js file to verify that when using the -u option, the file is correctly updated.

## Usage

## Additional Information

After downloading the data file with `./htbmachines.sh -u`, you can use the following commands for testing and exploring the dataset:

- List all machine names: `grep "name: " bundle.js`
- List all IP addresses: `grep "ip: " bundle.js`
- List all operating systems: `grep "so: " bundle.js`
- List all difficulty levels: `grep "dificultad: " bundle.js`
- List all skills: `grep "skills: " bundle.js`
- List all YouTube links: `grep "link: " bundle.js`

Note:
- Machine names and operating system inputs are case-insensitive.
- For single-word skills, quotes are not necessary. For multi-word skills, enclose the argument in quotes.

Examples:
./htbmachines.sh -s Enumeration
./htbmachines.sh -s "Web Enumeration"

## Download/Update Files
./htbmachines.sh -u

## Search by Machine Name
./htbmachines.sh -n <machine_name>

## Search by IP Address
./htbmachines.sh -i <ip_address>

## Search by Difficulty
Please enter the difficulty in Spanish, including the acute accent symbol (Fácil=Easy, Media=Medium, Difícil=Hard, Insane=Insane)

./htbmachines.sh -d <difficulty>

## Search by Operating System
./htbmachines.sh -o <operating_system>

## Search by Skill
./htbmachines.sh -s <skill>

## Show YouTube Resolution Link
./htbmachines.sh -y <machine_name>

## Show Help Panel
./htbmachines.sh -h

## Gratitude
Special thanks to S4vitar for his guidance and inspiration. You can explore his amazing courses and content on https://hack4u.io/
