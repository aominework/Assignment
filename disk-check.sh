#!/bin/bash

PATH_TO_CHECK="${2:-/}"
if [ -z "$1" ]; then
echo "Error: Threshold is required."
exit 2
fi
THRESHOLD="$1"
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
echo "Error: Threshold must be an integer from 1 to 100."
exit 2
fi
USAGE=$(df -P "$PATH_TO_CHECK" | awk 'NR==2 {print $5}' | tr -d '%')
echo "Disk usage for $PATH_TO_CHECK: ${USAGE}%"
if [ "$USAGE" -ge "$THRESHOLD" ]; then exit 1
fi
exit 0
