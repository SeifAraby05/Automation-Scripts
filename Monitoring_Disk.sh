#!/bin/bash

# Disk Usage Monitoring Script with Enhanced Graph Display

THRESHOLD=80  # Set threshold for disk usage percentage

# Colors for the graph display
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'  # No color

# Function to display usage as a graphical bar
print_usage_graph() {
    local DEVICE=$1
    local SIZE=$2
    local USED=$3
    local AVAIL=$4
    local USAGE=$5
    local MOUNT_POINT=$6
    local COLOR

    # Choose color based on usage level
    if [ "$USAGE" -ge 80 ]; then
        COLOR=$RED
    elif [ "$USAGE" -ge 50 ]; then
        COLOR=$YELLOW
    else
        COLOR=$GREEN
    fi

    # Display partition, size, used, available, and usage graph
    printf "${CYAN}%-20s${NC} %-7s %-7s %-7s %-15s : " "$DEVICE" "$SIZE" "$USED" "$AVAIL" "$MOUNT_POINT"
    printf "$COLOR"

    # Display graph bar with 5% increments
    for ((i=0; i<$USAGE; i+=5)); do
        printf "█"
    done

    # Display percentage with color reset
    printf " ${USAGE}%%${NC}\n"
}

# Function to check each mount point's usage
check_disk_usage() {
    echo -e "\nDisk Usage Report:"
    echo "----------------------------"
    echo -e "${CYAN}Partition           Size     Used     Avail    Mount Point      Usage${NC}"
    echo "-----------------------------------------------------------------------"

    # Loop through each disk/partition
    df -h | grep '^/dev/' | awk '{print $1 " " $2 " " $3 " " $4 " " $5 " " $6}' | while read -r line; do
        DEVICE=$(echo "$line" | awk '{print $1}')
        SIZE=$(echo "$line" | awk '{print $2}')
        USED=$(echo "$line" | awk '{print $3}')
        AVAIL=$(echo "$line" | awk '{print $4}')
        USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        MOUNT_POINT=$(echo "$line" | awk '{print $6}')

        # Print usage graph for each mount point
        print_usage_graph "$DEVICE" "$SIZE" "$USED" "$AVAIL" "$USAGE" "$MOUNT_POINT"

        # Check if usage exceeds threshold
        if [ "$USAGE" -ge "$THRESHOLD" ]; then
            echo -e "${RED}Warning:${NC} $DEVICE ($MOUNT_POINT) is at ${USAGE}% usage!"
        fi
        echo ""  # Add spacing between partitions
    done
    echo "-----------------------------------------------------------------------"
}

# Run the disk usage check function
check_disk_usage

