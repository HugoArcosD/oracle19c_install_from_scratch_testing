#!/bin/bash
# Nuke script para Oracle. Uso: sudo ./nuke_oracle.sh [-s|--software]

# 1. Check for root
if [ "$EUID" -ne 0 ]; then 
  echo "Error: Este script debe ejecutarse como root."
  exit 1
fi

# 2. Parse arguments
DELETE_SOFTWARE=false
if [[ "$1" == "-s" || "$1" == "--software" ]]; then
    DELETE_SOFTWARE=true
    echo "ADVERTENCIA: Se ha seleccionado el borrado TOTAL (incluyendo binarios)."
fi

echo "--- STARTING CLEANUP ---"

# 1. Kill oracle processes
echo "Deteniendo procesos..."
pkill -u oracle 2>/dev/null

# 2. Stop listeners
lsnrctl stop 2>/dev/null

# 3. Clean environment
rm -f /etc/oraInst.loc /etc/oratab

# 4. Wipe Data (Siempre se borra)
echo "Borrando archivos de datos, redo y fra..."
rm -rf /data/ora_temp01/* /data/ora_fra01/* /data/ora_redo01/* /data/ora_redo02/* /data/ora_data01/* /data/ora_data02/*

# 5. Conditional Software Wipe
if [ "$DELETE_SOFTWARE" = true ]; then
    echo "Borrando binarios de software en /opt/oracle/product..."
    rm -rf /opt/oracle/product/*
    rm -rf /opt/oracle/oraInventory/*
    rm -rf /home/oracle/.bash_profile
    rm -rf /home/oracle/.bashrc
else
    echo "Binarios de software mantenidos (Nivel 1: Data Only)."
fi

echo "--- CLEANUP FINISHED ---"

