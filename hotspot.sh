#!/bin/bash

uci -q delete network.hotspot_dev
uci set network.hotspot_dev="device"
uci set network.hotspot_dev.type="bridge"
uci set network.hotspot_dev.name="br-hotspot"
uci -q delete network.hotspot
uci set network.hotspot="interface"
uci set network.hotspot.proto="static"
uci set network.hotspot.device="br-hotspot"
uci set network.hotspot.ipaddr="192.168.1.1/24"
uci commit network
service network restart
sleep 2

uci set firewall.hotspot=zone
uci set firewall.hotspot.name='hotspot'
uci set firewall.hotspot.network='hotspot' 
uci set firewall.hotspot.input='REJECT'
uci set firewall.hotspot.output='REJECT'
uci set firewall.hotspot.forward='REJECT'

# Apply changes
uci commit firewall
/etc/init.d/firewall restart
