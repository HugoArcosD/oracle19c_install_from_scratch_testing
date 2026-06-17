#!/bin/bash
# Oracle Nuke script. Usage: sudo ./nuke_oracle.sh [-s|--software]

# 1. Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

# 2. Parse arguments
DELETE_SOFTWARE=false
if [[ "$1" == "-s" || "$1" == "--software" ]]; then
    DELETE_SOFTWARE=true
    echo ": WARNING: TOTAL NUKE INCLUDING ORACLE SOFTWARE BINARIES"
fi

echo "--- STARTING CLEANUP ---"

# 1. Kill oracle processes
echo "Stopping Oracle processes..."
pkill -u oracle 2>/dev/null

# 2. Stop listeners
lsnrctl stop 2>/dev/null

# 3. Clean environment
rm -f /etc/oraInst.loc /etc/oratab

# 4. Wipe Data
echo "Deleting database files..."
rm -rf /data/ora_temp01/* /data/ora_fra01/* /data/ora_redo01/* /data/ora_redo02/* /data/ora_data01/* /data/ora_data02/*

# 5. Conditional Software Wipe
if [ "$DELETE_SOFTWARE" = true ]; then
    echo "Deleting software binaries in /opt/oracle/product..."
    rm -rf /opt/oracle/product/*
    rm -rf /opt/oracle/oraInventory/*
    rm -rf /home/oracle/.bash_profile
    rm -rf /home/oracle/.bashrc
else
    echo "Software binaries retained (Level 1: Data Only cleanup)."
fi

echo "--- CLEANUP FINISHED ---"

