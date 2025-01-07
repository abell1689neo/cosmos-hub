#!/usr/bin/env bash

BIN=${BIN:=$(which gaiad 2>/dev/null)}

if [ -z "$BIN" ]; then
    echo "$BIN is not set."
    exit 1
fi

echo "Using $BIN"

NODES=("node1" "node2" "node3" "node4")

for i in ${!NODES[@]}; do
    NODE_HOME="/Users/user/test/${NODES[$i]}"

    # Ensure the node directory exists
    if [ ! -d "$NODE_HOME" ]; then
        echo "Error: $NODE_HOME does not exist. Please run init_nodes.sh first."
        exit 1
    fi

    # Start the node in the background
    echo "Starting ${NODES[$i]}..."
    $BIN start --home "$NODE_HOME" > "$NODE_HOME/node.log" 2>&1 &
    echo "${NODES[$i]} started. Logs: $NODE_HOME/node.log"
done

# Show all running processes
echo "All nodes started. Running processes:"
ps aux | grep "$BIN" | grep -v grep
