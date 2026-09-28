#!/bin/bash

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/network-check.log"

mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

if [ -z "$1" ]; then
    echo "Error: Host is required."
    log "Error: Host is required."
    exit 2
fi

HOST="$1"
PORT="$2"

log "Starting network check for $HOST"

RESOLVED_IP=$(getent hosts "$HOST" | awk '{print $1}' | head -n 1)

if [ -z "$RESOLVED_IP" ]; then
    echo "Error: Unable to resolve hostname '$HOST'."
    log "Error: Unable to resolve hostname '$HOST'"
    exit 2
fi

echo "Resolved IP for $HOST: $RESOLVED_IP"
log "Resolved $HOST to $RESOLVED_IP"

if ping -c 1 -w 2 "$HOST" > /dev/null 2>&1; then
    echo "connectivity: OK"
    log "Connectivity check: OK"
else
    echo "connectivity: FAILED"
    log "Connectivity check: FAILED"
fi

echo "Network Interfaces:"
ip addr
log "Displayed network interfaces"

if [ -n "$PORT" ]; then
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "Error: Port must be an integer from 1 to 65535."
        log "Error: Invalid port '$PORT'"
        exit 2
    fi

    log "Checking TCP port $PORT on $HOST"

    if timeout 3 bash -c "</dev/tcp/$HOST/$PORT" 2>/dev/null; then
        echo "Port $PORT on $HOST: OPEN"
        log "Port $PORT on $HOST: OPEN"
    else
        echo "TCP port $PORT on $HOST: CLOSED or unreachable"
        log "TCP port $PORT on $HOST: CLOSED or unreachable"
    fi
fi

log "Network check completed for $HOST"