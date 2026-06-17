#!/bin/bash
# Run as ORACLE user

# 1. Validate that the ORACLE_SID parameter was provided
if [ -z "$1" ]; then
    echo "ERROR: ORACLE_SID parameter is missing."
    echo "Usage: $0 <ORACLE_SID>"
    echo "Example: $0 TESTDB1"
    exit 1
fi

export ORACLE_SID=$1
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

# Must match the password used during creation
SYS_PASS="SysPassword123#"

echo "======================================================="
echo "Starting Enterprise Database Deletion for: ${ORACLE_SID}"
echo "======================================================="

# Ensure the database is running so DBCA can connect and drop it
echo "Step 1: Starting database (if down) to allow DBCA to drop it..."
sqlplus -s / as sysdba <<EOF
startup;
exit;
EOF

echo "Step 2: Launching DBCA to safely drop the database ${ORACLE_SID}..."
# DBCA will remove datafiles, control files, redo logs, and the spfile
dbca -silent -deleteDatabase \
     -sourceDB ${ORACLE_SID} \
     -sysDBAUserName sys \
     -sysDBAPassword ${SYS_PASS}

echo "Step 3: Cleaning up custom enterprise directories for ${ORACLE_SID}..."
# Remove the specific directories created for this SID
rm -rf /data/ora_data01/${ORACLE_SID}
rm -rf /data/ora_data02/${ORACLE_SID}
rm -rf /data/ora_redo01/${ORACLE_SID}
rm -rf /data/ora_redo02/${ORACLE_SID}
rm -rf /data/ora_fra01/${ORACLE_SID}

# Also clean up the audit dumps for this SID to leave no trace
rm -rf /opt/oracle/admin/${ORACLE_SID}

echo "======================================================="
echo "Database ${ORACLE_SID} has been completely removed."
echo "======================================================="
