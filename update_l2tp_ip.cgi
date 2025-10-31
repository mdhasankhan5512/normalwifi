#!/bin/sh
# /www/update_l2tp_ip.cgi
# Make executable: chmod +x /www/update_l2tp_ip.cgi

echo "Content-type: text/plain"
echo ""

# --- Read IP from GET or POST ---
if [ "$REQUEST_METHOD" = "GET" ]; then
    IP=$(echo "$QUERY_STRING" | sed -n 's/^.*ip=\([^&]*\).*$/\1/p')
elif [ "$REQUEST_METHOD" = "POST" ]; then
    read POST_DATA
    IP=$(echo "$POST_DATA" | sed -n 's/^.*ip=\([^&]*\).*$/\1/p')
fi

# --- Validate IP ---
if ! echo "$IP" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "Error: Invalid or missing IP address."
    exit 1
fi

# --- Interface name (change if needed) ---
IFACE="client"

# --- Update L2TP server address in /etc/config/network ---
# Find the section for the L2TP interface
SECTION=$(uci show network | grep "network.*\.ifname='$IFACE'" | cut -d'.' -f2 | head -n1)
if [ -z "$SECTION" ]; then
    SECTION=$IFACE
fi

# Set new server IP
uci set network.$SECTION.server="$IP"
uci commit network

# --- Restart the L2TP interface ---
ifup $IFACE 2>/dev/null || {
    echo "Restarting network service..."
    /etc/init.d/network restart >/dev/null 2>&1
}

echo "L2TP interface '$IFACE' updated to server IP: $IP"
