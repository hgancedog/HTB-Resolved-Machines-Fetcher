# HTB-Resolved-Machines-Fetcher
An interactive bash script for fetching and managing data of resolved HackTheBox machines, inspired by S4vitar, a Spanish professional cybersecurity specialist. It maintains original menu options for coherence but features unique and original programming logic.

## Features

- **Download/Update Necessary Files**: Download or update files containing the machine data.
- **Search by Machine Name**: Search for information about a resolved machine by its name.
- **Search by IP Address**: Find machines based on their IP address.
- **Search by Difficulty**: Filter machines by their difficulty level.
- **Search by Operating System**: Search for machines by their operating system.
- **Search by Skill**: Filter machines by specific skills (e.g., SQLI, Buffer Overflow, XSS, etc.).
- **Show YouTube Resolution Link**: Display the link to the machine's resolution on YouTube.
- **Help Panel**: Show the help panel with the available options.

## Usage

To run the script, make sure you have bash installed and execute the following command:

bash
./htb_machine_fetcher.sh

## Download/Update Files
./htb_machine_fetcher.sh -u

## Search by Machine Name
./htb_machine_fetcher.sh -n <machine_name>

## Search by IP Address
./htb_machine_fetcher.sh -i <ip_address>

## Search by Difficulty
Please enter the difficulty in Spanish, including the acute accent symbol (Fácil=Easy, Media=Medium, Difícil=Hard, Insane=Insane)

./htb_machine_fetcher.sh -d <difficulty>

## Search by Operating System
./htb_machine_fetcher.sh -o <operating_system>

## Search by Skill
./htb_machine_fetcher.sh -s <skill>

## Show YouTube Resolution Link
./htb_machine_fetcher.sh -y <machine_name>

## Show Help Panel
./htb_machine_fetcher.sh -h

## Gratitude

Special thanks to S4vitar for his guidance and inspiration. You can explore his amazing courses and content on https://hack4u.io/
