#!/bin/bash
# Script för att visa nätverksanvändning på noden (RX/TX)
# Beräknar per timme, dag, månad och år

clear
echo "🌐 Proxmox Node Network Monitor"
echo "==============================="

# Hostname & IP
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
echo "🖥️ Hostname: $HOSTNAME"
echo "🌐 IP: $IP"
echo "==============================="

# Hämta RX/TX bytes från alla aktiva gränssnitt (exkludera lo)
INTERFACES=$(ls /sys/class/net | grep -v lo)

TOTAL_RX=0
TOTAL_TX=0

for IFACE in $INTERFACES; do
    RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
    TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
    TOTAL_RX=$((TOTAL_RX + RX))
    TOTAL_TX=$((TOTAL_TX + TX))
done

# Omvandla till MB
RX_MB=$(echo "scale=2; $TOTAL_RX/1024/1024" | bc)
TX_MB=$(echo "scale=2; $TOTAL_TX/1024/1024" | bc)

echo "📥 Total mottagen data: $RX_MB MB"
echo "📤 Total skickad data:  $TX_MB MB"

# Beräkna per månad/år med antagande: noden kör hela tiden
HOURS_PER_DAY=24
DAYS_PER_MONTH=30
DAYS_PER_YEAR=365

# Snabb uppskattning: data sedan senaste reboot
# Hämta uptime
UPTIME_SEC=$(cut -d. -f1 /proc/uptime)
UPTIME_HOURS=$(echo "scale=2; $UPTIME_SEC/3600" | bc)

# Data per timme
RX_PER_HOUR=$(echo "scale=2; $RX_MB/$UPTIME_HOURS" | bc)
TX_PER_HOUR=$(echo "scale=2; $TX_MB/$UPTIME_HOURS" | bc)

# Per dag/månad/år
RX_PER_DAY=$(echo "scale=2; $RX_PER_HOUR*$HOURS_PER_DAY" | bc)
TX_PER_DAY=$(echo "scale=2; $TX_PER_HOUR*$HOURS_PER_DAY" | bc)

RX_PER_MONTH=$(echo "scale=2; $RX_PER_DAY*$DAYS_PER_MONTH" | bc)
TX_PER_MONTH=$(echo "scale=2; $TX_PER_DAY*$DAYS_PER_MONTH" | bc)

RX_PER_YEAR=$(echo "scale=2; $RX_PER_DAY*$DAYS_PER_YEAR" | bc)
TX_PER_YEAR=$(echo "scale=2; $TX_PER_DAY*$DAYS_PER_YEAR" | bc)

echo "==============================="
echo "📊 Uppskattad nätverkstrafik:"
echo "Per timme:  📥 $RX_PER_HOUR MB | 📤 $TX_PER_HOUR MB"
echo "Per dag:     📥 $RX_PER_DAY MB | 📤 $TX_PER_DAY MB"
echo "Per månad:   📥 $RX_PER_MONTH MB | 📤 $TX_PER_MONTH MB"
echo "Per år:      📥 $RX_PER_YEAR MB | 📤 $TX_PER_YEAR MB"
echo "==============================="
