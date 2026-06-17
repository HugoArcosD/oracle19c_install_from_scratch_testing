#!/bin/bash
# Run as ORACLE user

# 1. Define defaults
LISTENER_NAME=${1:-LISTENER}
PORT=${2:-1521}

export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH
TNS_DIR=$ORACLE_HOME/network/admin

mkdir -p $TNS_DIR

echo "======================================================="
echo "Configuring Listener: $LISTENER_NAME on port $PORT"
echo "======================================================="

# 2. Check if listener.ora exists
if [ ! -f "$TNS_DIR/listener.ora" ]; then
    echo "Creating new listener.ora file..."
    cat <<EOF > $TNS_DIR/listener.ora
$LISTENER_NAME =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = $PORT))
    )
  )
EOF
else
    # Check if the listener already exists in the file to avoid duplicates
    if grep -q "$LISTENER_NAME" "$TNS_DIR/listener.ora"; then
        echo "Listener $LISTENER_NAME already exists in listener.ora. Skipping."
    else
        echo "Adding $LISTENER_NAME to existing listener.ora..."
        cat <<EOF >> $TNS_DIR/listener.ora

$LISTENER_NAME =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = $PORT))
    )
  )
EOF
    fi
fi

# 3. Start the listener
echo "Starting $LISTENER_NAME..."
lsnrctl start $LISTENER_NAME
lsnrctl status $LISTENER_NAME

echo "======================================================="
echo "Listener setup for $LISTENER_NAME completed."

