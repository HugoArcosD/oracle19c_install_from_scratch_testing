#!/bin/bash
# Run as ORACLE user

# 1. Parameter validation
if [ -z "$1" ]; then
    echo "ERROR: Missing parameter."
    echo "Usage: $0 <LISTENER_NAME>"
    exit 1
fi

LISTENER_NAME=$1
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
TNS_DIR=$ORACLE_HOME/network/admin
LISTENER_FILE="$TNS_DIR/listener.ora"

echo "======================================================="
echo "Removing Listener: $LISTENER_NAME"
echo "======================================================="

# 2. Stop the listener
echo "Stopping $LISTENER_NAME..."
lsnrctl stop $LISTENER_NAME

# 3. Remove from listener.ora
if [ -f "$LISTENER_FILE" ]; then
    echo "Cleaning $LISTENER_FILE..."
    
    # We use sed to remove the block associated with the listener.
    # This assumes the standard block format defined in your creation script.
    sed -i "/$LISTENER_NAME =/,/)/d" "$LISTENER_FILE"
    
    # Remove any extra empty lines created by the sed deletion
    sed -i '/^$/d' "$LISTENER_FILE"
    
    echo "Configuration for $LISTENER_NAME removed."
else
    echo "Warning: listener.ora file not found."
fi

echo "======================================================="
echo "Listener $LISTENER_NAME successfully dropped."

