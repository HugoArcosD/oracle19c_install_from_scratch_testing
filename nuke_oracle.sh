#!/bin/bash
# Nuke script for Oracle. Usage: sudo ./nuke_oracle.sh [-s|--software]

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

# 2. Parse arguments
DELETE_SOFTWARE=false
if [[ "$1" == "-s" || "$1" == "--software" ]]; then
    DELETE_SOFTWARE=true
    echo "======================================================="
    echo " WARNING: TOTAL NUKE INCLUDING BINARIES AND RPM PACKAGES"
    echo "======================================================="
fi

echo "--- STARTING CLEANUP ---"

# 3. Kill Oracle processes
echo "-> Stopping all processes for the oracle user..."
pkill -u oracle 2>/dev/null
sleep 2 # Give a margin for processes to terminate correctly

# 4. Clean environment files
echo "-> Removing global configuration files (/etc/oratab, oraInst.loc)..."
rm -f /etc/oraInst.loc /etc/oratab

# 5. Wipe Data (Datafiles, Redo, FRA)
echo "-> Deleting database files..."
rm -rf /data/ora_temp01/* /data/ora_fra01/* /data/ora_redo01/* /data/ora_redo02/* /data/ora_data01/* /data/ora_data02/*
# (Optional) Wipe default RPM path just in case
rm -rf /opt/oracle/oradata/* 2>/dev/null

# 6. Conditional Software Wipe (Dynamic Detection)
if [ "$DELETE_SOFTWARE" = true ]; then
    echo "-> Detecting installed Oracle Database packages..."
    # Find any installed package starting with "oracle-database" but ignore "preinstall"
    ORACLE_DB_PKGS=$(rpm -qa | grep "^oracle-database" | grep -v "preinstall")
    
    if [ -n "$ORACLE_DB_PKGS" ]; then
        echo "-> Found the following packages to uninstall:"
        echo "$ORACLE_DB_PKGS"
        
        for pkg in $ORACLE_DB_PKGS; do
            echo "   Uninstalling $pkg..."
            yum remove -y "$pkg" 2>/dev/null || dnf remove -y "$pkg" 2>/dev/null
        done
    else
        echo "-> No Oracle Database RPM packages found in the system."
    fi
    
    echo "-> Removing remaining binaries in /opt/oracle/product..."
    rm -rf /opt/oracle/product/*
    
    echo "-> Removing Oracle inventory (oraInventory)..."
    rm -rf /opt/oracle/oraInventory
    
    echo "-> Cleaning package manager cache..."
    yum clean all 2>/dev/null || dnf clean all 2>/dev/null
fi

echo "--- CLEANUP COMPLETE ---"
echo "The environment has been cleaned. You can now run your installation script from scratch."

