#!/bin/bash

# Default port
PORT=443

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to scan a single host
scan_host() {
    local host=$1
    echo "Scanning $host on port $PORT for RC4 cipher suites..."
    if nmap -p $PORT --script ssl-enum-ciphers $host | grep -iq "RC4"; then
        echo -e "${RED}Vulnerable to Bar Mitzvah: $host${NC}"
    else
        echo -e "${GREEN}NOT Vulnerable to Bar Mitzvah: $host${NC}"
    fi
}

# Parse command line options
while getopts ":iL:p:" opt; do
  case ${opt} in
    iL )
      input_list=$OPTARG
      ;;
    p )
      PORT=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      exit 1
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Main logic
if [ -n "$input_list" ]; then
    # If -iL is used, read targets from the provided file
    while IFS= read -r line; do
        scan_host "$line"
    done < "$input_list"
elif [ $# -gt 0 ]; then
    # If there are arguments left, use them as targets
    for target in "$@"; do
        scan_host "$target"
    done
else
    echo "Usage: $0 [-p port] [-iL input_list] <target1> [target2] ..."
    exit 1
fi
