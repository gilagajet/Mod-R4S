#!/bin/bash
#=================================================
# File name: init-settings.sh
# Description: This script will be executed during the first boot
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================
#--------------------------------------------------------
#   If you use some codes frome here, please give credit to www.helmiau.com
#--------------------------------------------------------

# Disable autostart by default for some packages
rm -f /etc/rc.d/S99dockerd || true
rm -f /etc/rc.d/S99dockerman || true
rm -f /etc/rc.d/S30stubby || true
rm -f /etc/rc.d/S90stunnel || true

# Check file system during boot
uci set fstab.@global[0].check_fs=1
uci commit

# Disable opkg signature check
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf

#-----------------------------------------------------------------------------
#   Start of @helmiau additionals menu
#-----------------------------------------------------------------------------

# Set Argon theme to light on first boot
uci set argon.@global[0].mode='light'

# Set hostname to HelmiWrt
uci set system.@system[0].hostname='OpenWRT'

# Set Timezone to Asia/Jakarta
uci set system.@system[0].timezone='MYT-8'
uci set system.@system[0].zonename='Asia/Kuala Lumpur'
uci commit system

# Set default wifi name to HelmiWrt
#sed -i "s/#option ssid 'OpenWrt'/#option ssid 'R4S'/g" /etc/config/wireless

# Add shadowsocksr shortcut
#chmod +x /bin/ssr

# Added neofetch on oh-my-zsh
#echo "neofetch" > /root/.oh-my-zsh/custom/example.zsh
#chmod +x /bin/neofetch
#neofetch
#rm -rf neofetch.old

# Vmess creator shortcut
#chmod +x /bin/vmess

# Add ram checker from wegare123
# run "ram" using terminal to check ram usage
#chmod +x /bin/ram

# Add fix download file.php for xderm and libernet
# run "fixphp" using terminal for use
#chmod +x /bin/fixphp
#fixphp

# Add IP Address Info Checker
# run "myip" using terminal for use
chmod +x /bin/myip

# Add Samba Allowed Guest Setup
# run "sambaset" using terminal to set it up
#chmod +x /bin/sambaset

# Add refresh IP Address for QMI Modems, such as LT4220
# Script by Rudi Hartono https://www.facebook.com/rud18
#chmod +x /bin/ipqmi

# Fix luci-app-atinout-mod by 4IceG
#chmod +x /usr/bin/luci-app-atinout

# Fix for xderm mini gui if trojan is not installed
#ln -sf /usr/sbin/trojan /usr/bin/trojan

# HelmiWrt Patches
#chmod +x /bin/helmiwrt
#helmiwrt
#rm -rf helmiwrt.old

# HelmiWrt Patches
#if ! grep -q "helmiwrt" /etc/rc.local; then
#	sed -i 's#exit 0#\n#g' /etc/rc.local
#	cat << 'EOF' >> /etc/rc.local
#
#chmod +x /bin/helmiwrt
#/bin/helmiwrt
#exit 0
#EOF
#	logger "  gigalog : helmipatch already applied to on-boot..."
#	echo -e "  gigalog : helmipatch already applied to on-boot..."
#fi

# Set default theme to luci-theme-argon
# Delete default watchcat setting
# Set Google DNS as default DNS Forwarding
cat << 'EOF' > /bin/default-theme

uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

#uci delete system.@watchcat
#uci commit
#/etc/init.d/watchcat restart

#uci add_list dhcp.@dnsmasq[0].server='8.8.8.8'
#uci add_list dhcp.@dnsmasq[0].server='9.9.9.9'
#uci add_list dhcp.@dnsmasq[0].server='1.1.1.1'
#uci commit dhcp
#/etc/init.d/dnsmasq restart

EOF
chmod +x /bin/default-theme
default-theme

# Add my Load Balance settings
#chmod +x /bin/helmilb
#helmilb

# Add clashcs script : OpenClash Core switcher
#chmod +x /bin/ocsm

# Add : v2rayA Script Manager : This script will help you to install v2rayA software to your openwrt device
# read more about v2rayA here
#chmod +x /bin/vasm
#rm -r /bin/vasm

# Bye-bye zh_cn
opkg remove $(opkg list-installed | grep zh-cn)

# start v2rayA service on boot
#sed -i "s#option enabled.*#option enabled '1'#g" /etc/config/v2raya
#/etc/init.d/v2raya enable
#/etc/init.d/v2raya start
#/etc/init.d/v2raya reload
#/etc/init.d/v2raya restart
#rm -r /etc/init.d/v2raya

# activate TUN TAP interface
#/usr/sbin/openvpn --mktun --dev tun0
#/usr/sbin/openvpn --mktun --dev tun1

# Apply your own customization on boot features
#if grep -q "helmiwrt.sh" /boot/helmiwrt.sh; then
#	logger "  gigalog : detected helmiwrt.sh boot script, running script..."
#	echo -e "  gigalog : detected helmiwrt.sh boot script, running script..."
#	chmod +x /boot/helmiwrt.sh
#	./boot/helmiwrt.sh
#	logger "  gigalog : helmiwrt.sh boot script running done!"
#	echo -e "  gigalog : helmiwrt.sh boot script running done!"
#fi

# Disable etc/config/xmm-modem on boot first
#if [[ -f /etc/config/xmm-modem ]]; then
#	logger "  gigalog : detected helmiwrt.sh boot script, running script..."
#	echo -e "  gigalog : detected helmiwrt.sh boot script, running script..."
#	sed -i "s#option enable.*#option enable '0'#g" /etc/config/xmm-modem
#	logger "  gigalog : helmiwrt.sh boot script running done!"
#	echo -e "  gigalog : helmiwrt.sh boot script running done!"
#fi

# Set Custom TTL
cat << 'EOF' >> /etc/firewall.user

# Set Custom TTL
iptables -t mangle -I POSTROUTING -o  -j TTL --ttl-set 64
iptables -t mangle -I PREROUTING -i  -j TTL --ttl-set 64
ip6tables -t mangle -I POSTROUTING ! -p icmpv6 -o  -j HL --hl-set 64
ip6tables -t mangle -I PREROUTING ! -p icmpv6 -i  -j HL --hl-set 64

EOF
/etc/config/firewall restart

# Fix Architecture overview for s9xxx amlogic and Uninstall luci-app-amlogic for Raspberry Pi 3
#if grep -q "amlogic" /sbin/cpuinfo; then
#	sed -i "s#bcm27xx/bcm2710#armvirt/64#iIg" /etc/openwrt_release
#else
#	opkg remove luci-app-amlogic
#fi

# Fix 3ginfo
#chmod +x /etc/init.d/3ginfo
#chmod +x /usr/share/3ginfo/scripts/*
#chmod +x /usr/share/3ginfo/cgi-bin/*

# Fix xdrtool: Xderm Mini Tool Script permission
#chmod +x /bin/xdrtool

# Fix atinout permission
#chmod +x /sbin/set_at_port.sh

# Fix sms tool
#chmod +x /etc/init.d/smsled
#chmod +x /sbin/cronsync.sh
#chmod +x /sbin/set_sms_ports.sh
#chmod +x /sbin/smsled-init.sh
#chmod +x /sbin/smsled.sh

# Add wegare123 stl tool
# run "stl" using terminal for use
#chmod +x /usr/bin/gproxy
#chmod +x /usr/bin/stl
#chmod +x /root/akun/tunnel.py
#chmod +x /root/akun/ssh.py
#chmod +x /root/akun/inject.py
#chmod +x /usr/bin/autorekonek-stl
#mkdir -p /root/.ssh/
#touch /root/akun/ssl.conf
#touch /root/.ssh/config
#touch /root/akun/stl.txt
#touch /root/akun/ipmodem.txt 

# Add wifi id seamless autologin by kopijahe
# run "kopijahe" using terminal for use
#chmod +x /bin/kopijahe

#-----------------------------------------------------------------------------
#   Start of @helmiau additionals menu
#-----------------------------------------------------------------------------

# LuCI -> System -> Terminal (a.k.a) luci-app-ttyd without login
if ! grep -q "/bin/login -f root" /etc/config/ttyd; then
	cat << "EOF" > /etc/config/ttyd
config ttyd
	option interface '@lan'
	option command '/bin/login -f root'
EOF
	logger "  log : Terminal ttyd patched..."
	echo -e "  log : Terminal ttyd patched..."
fi

exit 0
