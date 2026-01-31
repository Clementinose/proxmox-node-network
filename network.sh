#!/bin/bash
# Script för att visa nätverksanvändning på noden (RX/TX)
# Visar MB, GB och TB samt uppskattning per timme, dag, månad och år

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

# Funktion för att konvertera bytes till MB, GB, TB
convert_sizes() {
    BYTES=$1
    MB=$(echo "scale=2; $BYTES/1024/1024" | bc)
    GB=$(echo "scale=2; $BYTES/1024/1024/1024" | bc)
    TB=$(echo "scale=2; $BYTES/1024/1024/1024/1024" | bc)
    echo "$MB MB | $GB GB | $TB TB"
}

RX_STR=$(convert_sizes $TOTAL_RX)
TX_STR=$(convert_sizes $TOTAL_TX)

echo "📥 Total mottagen data: $RX_STR"
echo "📤 Total skickad data:  $TX_STR"

# Beräkna per månad/år med antagande: noden kör hela tiden
HOURS_PER_DAY=24
DAYS_PER_MONTH=30
DAYS_PER_YEAR=365

# Snabb uppskattning: data sedan senaste reboot
UPTIME_SEC=$(cut -d. -f1 /proc/uptime)
UPTIME_HOURS=$(echo "scale=2; $UPTIME_SEC/3600" | bc)

RX_PER_HOUR=$(echo "scale=2; $TOTAL_RX/$UPTIME_HOURS" | bc)
TX_PER_HOUR=$(echo "scale=2; $TOTAL_TX/$UPTIME_HOURS" | bc)

RX_PER_DAY=$(echo "scale=2; $RX_PER_HOUR*$HOURS_PER_DAY" | bc)
TX_PER_DAY=$(echo "scale=2; $TX_PER_HOUR*$HOURS_PER_DAY" | bc)

RX_PER_MONTH=$(echo "scale=2; $RX_PER_DAY*$DAYS_PER_MONTH" | bc)
TX_PER_MONTH=$(echo "scale=2; $TX_PER_DAY*$DAYS_PER_MONTH" | bc)

RX_PER_YEAR=$(echo "scale=2; $RX_PER_DAY*$DAYS_PER_YEAR" | bc)
TX_PER_YEAR=$(echo "scale=2; $TX_PER_DAY*$DAYS_PER_YEAR" | bc)

# Konvertera även uppskattad trafik till MB|GB|TB
echo "==============================="
echo "📊 Uppskattad nätverkstrafik:"
echo "Per timme:  📥 $(convert_sizes $RX_PER_HOUR) | 📤 $(convert_sizes $TX_PER_HOUR)"
echo "Per dag:     📥 $(convert_sizes $RX_PER_DAY) | 📤 $(convert_sizes $TX_PER_DAY)"
echo "Per månad:   📥 $(convert_sizes $RX_PER_MONTH) | 📤 $(convert_sizes $TX_PER_MONTH)"
echo "Per år:      📥 $(convert_sizes $RX_PER_YEAR) | 📤 $(convert_sizes $TX_PER_YEAR)"
echo "==============================="
