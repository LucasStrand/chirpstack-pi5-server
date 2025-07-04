#!/bin/bash

# Gateway configuration helper script for ChirpStack
# Supports common LoRa concentrator hardware

set -e

echo "========================================="
echo "LoRa Gateway Configuration Helper"
echo "========================================="

# Get Pi's IP address
PI_IP=$(hostname -I | awk '{print $1}')

echo "Your Raspberry Pi IP address: $PI_IP"
echo ""

# Menu for gateway selection
echo "Select your LoRa gateway hardware:"
echo "1) RAK2245 / RAK2247"
echo "2) Seeed WM1302 (SPI)"
echo "3) Seeed WM1302 (USB)"
echo "4) iC880A"
echo "5) RisingHF RHF0M301"
echo "6) Generic Semtech UDP Packet Forwarder"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        echo "RAK2245/2247 Configuration"
        echo "=========================="
        echo "For RAK gateways, update your gateway configuration:"
        echo "- Server address: $PI_IP"
        echo "- Server port (up): 1700"
        echo "- Server port (down): 1700"
        echo ""
        echo "If using the RAK gateway OS, edit:"
        echo "/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/global_conf.json"
        ;;
    2)
        echo "Seeed WM1302 SPI Configuration"
        echo "=============================="
        echo "Install the SX1302 HAL:"
        echo "git clone https://github.com/Lora-net/sx1302_hal.git"
        echo "cd sx1302_hal"
        echo "make"
        echo ""
        echo "Edit packet_forwarder/global_conf.json:"
        echo "- server_address: $PI_IP"
        echo "- serv_port_up: 1700"
        echo "- serv_port_down: 1700"
        ;;
    3)
        echo "Seeed WM1302 USB Configuration"
        echo "=============================="
        echo "The WM1302 USB version typically uses the"
        echo "Semtech UDP packet forwarder."
        echo ""
        echo "Configure with:"
        echo "- Server address: $PI_IP"
        echo "- Server port: 1700"
        ;;
    4)
        echo "iC880A Configuration"
        echo "===================="
        echo "Install the packet forwarder:"
        echo "git clone https://github.com/Lora-net/packet_forwarder.git"
        echo "cd packet_forwarder"
        echo "make"
        echo ""
        echo "Update local_conf.json:"
        echo "{"
        echo "  \"gateway_conf\": {"
        echo "    \"server_address\": \"$PI_IP\","
        echo "    \"serv_port_up\": 1700,"
        echo "    \"serv_port_down\": 1700"
        echo "  }"
        echo "}"
        ;;
    5)
        echo "RisingHF RHF0M301 Configuration"
        echo "==============================="
        echo "Use the provided packet forwarder and configure:"
        echo "- Server: $PI_IP"
        echo "- Port: 1700"
        echo ""
        echo "Edit the configuration file provided with your gateway"
        ;;
    6)
        echo "Generic Semtech UDP Configuration"
        echo "================================="
        echo "For any gateway using Semtech UDP protocol:"
        echo "- Server address: $PI_IP"
        echo "- Server port (uplink): 1700"
        echo "- Server port (downlink): 1700"
        echo "- Protocol: Semtech UDP"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "========================================="
echo "Additional Configuration Notes:"
echo "========================================="
echo ""
echo "1. Gateway EUI: Your gateway needs a unique 64-bit EUI"
echo "   You can generate one based on your Pi's MAC address:"

# Get MAC address and create EUI
MAC=$(cat /sys/class/net/eth0/address 2>/dev/null || cat /sys/class/net/wlan0/address)
EUI=$(echo $MAC | sed 's/://g')FFFE000000
echo "   Suggested EUI: $EUI"

echo ""
echo "2. Frequency Plan: Make sure your gateway uses the correct"
echo "   frequency plan for your region:"
echo "   - EU868: Europe"
echo "   - US915: North America"
echo "   - AS923: Asia"
echo "   - AU915: Australia"
echo ""
echo "3. After configuring your gateway, register it in ChirpStack:"
echo "   - Log into ChirpStack at http://$PI_IP:8080"
echo "   - Go to Gateways -> Add Gateway"
echo "   - Enter your Gateway EUI"
echo "   - Select your region/frequency plan"
echo ""
echo "4. To test your gateway connection:"
echo "   docker-compose logs -f chirpstack-gateway-bridge"
echo "   You should see connection messages when the gateway connects"
echo ""

# Create example local_conf.json
cat > example_local_conf.json << EOF
{
  "gateway_conf": {
    "gateway_ID": "$EUI",
    "server_address": "$PI_IP",
    "serv_port_up": 1700,
    "serv_port_down": 1700,
    "keepalive_interval": 10,
    "stat_interval": 30,
    "push_timeout_ms": 100,
    "forward_crc_valid": true,
    "forward_crc_error": false,
    "forward_crc_disabled": false
  }
}
EOF

echo "An example local_conf.json has been created in this directory"
echo "for reference." 