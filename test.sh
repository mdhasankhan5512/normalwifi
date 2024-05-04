#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Creating Normal Wifi${NC}"

sleep 2 

echo -e "${YELLOW}Setting up bridge for Normal Wifi${NC}"
uci -q delete network.normal_wifi_dev
uci set network.normal_wifi_dev="device"
uci set network.normal_wifi_dev.type="bridge"
uci set network.normal_wifi_dev.name="br-normal_wifi"
uci -q delete network.normal_wifi
uci set network.normal_wifi="interface"
uci set network.normal_wifi.proto="static"
uci set network.normal_wifi.device="br-normal_wifi"
uci set network.normal_wifi.ipaddr="192.168.1.1/24"
uci commit network
service network restart

sleep 5
echo -e "${YELLOW}Configuring wireless settings for Normal Wifi${NC}"


WIFI_DEV="$(uci get wireless.@wifi-iface[0].device)"
uci -q delete wireless.normal_wifi
uci set wireless.normal_wifi="wifi-iface"
uci set wireless.normal_wifi.device="${WIFI_DEV}"
uci set wireless.normal_wifi.mode="ap"
uci set wireless.normal_wifi.network="normal_wifi"
uci set wireless.normal_wifi.ssid="normal wifi"
uci set wireless.normal_wifi.encryption="none"
uci commit wireless
wifi reload

sleep 5

echo -e "${YELLOW}Setting up DHCP for Normal Wifi${NC}"
uci -q delete dhcp.normal_wifi
uci set dhcp.normal_wifi="dhcp"
uci set dhcp.normal_wifi.interface="normal_wifi"
uci set dhcp.normal_wifi.start="100"
uci set dhcp.normal_wifi.limit="150"
uci set dhcp.normal_wifi.leasetime="1h"
uci commit dhcp
service dnsmasq restart

sleep 5

echo -e "${YELLOW}Configuring firewall rules for Normal Wifi${NC}"
uci -q delete firewall.normal_wifi
uci set firewall.normal_wifi="zone"
uci set firewall.normal_wifi.name="normal_wifi"
uci set firewall.normal_wifi.network="normal_wifi"
uci set firewall.normal_wifi.input="REJECT"
uci set firewall.normal_wifi.output="ACCEPT"
uci set firewall.normal_wifi.forward="REJECT"
uci -q delete firewall.normal_wifi_wan
uci set firewall.normal_wifi_wan="forwarding"
uci set firewall.normal_wifi_wan.src="normal_wifi"
uci set firewall.normal_wifi_wan.dest="wan"
uci -q delete firewall.normal_wifi_dns
uci set firewall.normal_wifi_dns="rule"
uci set firewall.normal_wifi_dns.name="Allow-DNS-Normal-Wifi"
uci set firewall.normal_wifi_dns.src="normal_wifi"
uci set firewall.normal_wifi_dns.dest_port="53"
uci set firewall.normal_wifi_dns.proto="tcp udp"
uci set firewall.normal_wifi_dns.target="ACCEPT"
uci -q delete firewall.normal_wifi_dhcp
uci set firewall.normal_wifi_dhcp="rule"
uci set firewall.normal_wifi_dhcp.name="Allow-DHCP-Normal-Wifi"
uci set firewall.normal_wifi_dhcp.src="normal_wifi"
uci set firewall.normal_wifi_dhcp.dest_port="67"
uci set firewall.normal_wifi_dhcp.proto="udp"
uci set firewall.normal_wifi_dhcp.family="ipv4"
uci set firewall.normal_wifi_dhcp.target="ACCEPT"
uci commit firewall
service firewall restart

sleep 5

echo -e "${GREEN}Done! Your SSID has been created.${NC}"

echo "Powered By MD HASAN KHAN"
