#!/usr/bin/env bash

BIN=${BIN:=$(which gaiad 2>/dev/null)}

if [ -z "$BIN" ]; then
    echo "$BIN is not set."
    exit 1
fi

echo "Using $BIN"

NODES=("node1" "node2" "node3" "node4")
PORT_OFFSETS=(0 10 20 30)

# Step 1: Initialize all nodes and configure ports
for i in ${!NODES[@]}; do
    NODE_HOME="/Users/user/test/${NODES[$i]}"
    OFFSET=${PORT_OFFSETS[$i]}

    # Remove previous data if it exists
    if [ -d "$NODE_HOME" ]; then
        rm -rv "$NODE_HOME"
    fi

    # Initialize node
    $BIN init "${NODES[$i]}" --chain-id "test$i" --home "$NODE_HOME"

    $BIN config set client chain-id "test$i" --home "$NODE_HOME"
    $BIN config set client keyring-backend test  --home "$NODE_HOME"
    $BIN config set app api.enable true


    # Configure ports
    CONFIG_FILE="$NODE_HOME/config/config.toml"
    APP_FILE="$NODE_HOME/config/app.toml"

    sed -i.bak -e "s|26656|$((26656 + OFFSET))|g" $CONFIG_FILE  # P2P Port
    sed -i.bak -e "s|26657|$((26657 + OFFSET))|g" $CONFIG_FILE  # RPC Port
    sed -i.bak -e "s|1317|$((1317 + OFFSET))|g" $APP_FILE      # REST API Port

    # Set minimum gas price
    sed -i.bak -e 's|minimum-gas-prices = ".*"|minimum-gas-prices = "0.025stake"|g' $APP_FILE

    echo "Node ${NODES[$i]} initialized and ports configured."

    $BIN keys add "validator$i" --home "$NODE_HOME" --keyring-backend=test
    $BIN genesis add-genesis-account "validator$i" 1000000000stake --home "$NODE_HOME"
    echo "Genesis account for validator$i added."

    $BIN genesis gentx "validator$i" 1000000stake --chain-id "test$i" --home "$NODE_HOME"
    echo "Gentx for validator$i generated."

    $BIN genesis collect-gentxs --home "$NODE_HOME"
    echo "gentx files collected into genesis."


done
