#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Modify hostname
sed -i 's/OpenWrt/OpenWRT/g' package/base-files/files/bin/config_generate


# Add kernel build user
sed -i 's/CONFIG_KERNEL_BUILD_USER=""/CONFIG_KERNEL_BUILD_USER="gilagajet"/g' .config

# Add kernel build domain
sed -i 's/CONFIG_KERNEL_BUILD_DOMAIN=""/CONFIG_KERNEL_BUILD_DOMAIN="modem.my"/g' .config

# Enable WiFi Interface
sed -i 's/wireless.radio${devidx}.disabled=1/wireless.radio${devidx}.disabled=0/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# Banner Update
echo -e "          Built on "$(date +%Y.%m.%d)"\n -----------------------------------------------------" >> files/etc/banner

# Version Update
sed -i '/DISTRIB_DESCRIPTION/d' package/base-files/files/etc/openwrt_release
echo "DISTRIB_DESCRIPTION='GilaGajet build $(TZ=UTC+8 date "+%Y.%m.%d") @ OpenWrt'" >> package/base-files/files/etc/openwrt_release
sed -i '/DISTRIB_REVISION/d' package/base-files/files/etc/openwrt_release
echo "DISTRIB_REVISION='[V22]'" >> package/base-files/files/etc/openwrt_release

# Update TimeZone
sed -i 's/0.openwrt.pool.ntp.org/time.google.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/time.cloudflare.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/clock.sjc.he.net/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/my.pool.ntp.org/g' package/base-files/files/bin/config_generate

#-----------------------------------------------------------------------------

# HelmiWrt packages
pushd package
git clone --depth=1 https://github.com/helmiau/helmiwrt-packages
popd

# Add themes from kenzok8 openwrt-packages
pushd package
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-atmaterial_new kenzok8/luci-theme-atmaterial_new
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-edge kenzok8/luci-theme-edge
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-ifit kenzok8/luci-theme-ifit

svn co https://github.com/immortalwrt/luci/trunk/themes/luci-theme-bootstrap-mod

popd

#-----------------------------------------------------------------------------


# Mod zzz-default-settings
#pushd package/lean/default-settings/files
#sed -i '/http/d' zzz-default-settings
#sed -i '/18.06/d' zzz-default-settings
#export orig_version=$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
#export date_version=$(date -d "$(rdate -n -4 -p pool.ntp.org)" +'%Y-%m-%d')
#sed -i "s/${orig_version}/${orig_version} ${date_version}/g" zzz-default-settings
#sed -i "s/zh_cn/auto/g" zzz-default-settings
#sed -i "s/uci set system.@system[0].timezone=CST-8/uci set system.@system[0].hostname=Mi4AG\nuci set system.@system[0].timezone=MYT-8/g" zzz-default-settings
#sed -i "s/Shanghai/Kuala Lumpur/g" zzz-default-settings
#popd

# Fix mt76 wireless driver
pushd package/kernel/mt76
sed -i '/mt7662u_rom_patch.bin/a\\techo mt76-usb disable_usb_sg=1 > $\(1\)\/etc\/modules.d\/mt76-usb' Makefile
popd

#-----------------------------------------------------------------------------

# Add luci-app-ssr-plus
pushd package
git clone --depth=1 https://github.com/fw876/helloworld
#[ ! -d helloworld/luci-app-ssr-plus ] && svn co https://github.com/NueXini/NueXini_Packages/trunk/luci-app-ssr-plus helloworld/luci-app-ssr-plus
popd

# Add luci-app-passwall from kenzok
pushd package
git clone --depth=1 https://github.com/kenzok8/openwrt-packages
git clone --depth=1 https://github.com/kenzok8/small-package
popd

# Add luci-app-passwall
pushd package
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall
[ ! -d openwrt-passwall/luci-app-passwall ] && svn co https://github.com/NueXini/NueXini_Packages/trunk/luci-app-passwall openwrt-passwall/luci-app-passwall
sed -i 's/ upx\/host//g' openwrt-passwall/v2ray-plugin/Makefile
grep -lr upx/host openwrt-passwall/* | xargs -t -I {} sed -i '/upx\/host/d' {}
popd

# Add OpenClash
pushd package
git clone --depth=1 -b master https://github.com/vernesong/OpenClash
popd

# Add luci-app-vssr
pushd package
git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb.git
git clone --depth=1 https://github.com/jerrykuku/luci-app-vssr
popd

# Add luci-app-wrtbwmon
pushd package
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-wrtbwmon
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/wrtbwmon
popd

#-----------------------------------------------------------------------------
# Zram Source from ImmortalWRT
pushd package/system
rm -r zram-swap
svn co https://github.com/immortalwrt/immortalwrt/trunk/package/system/zram-swap 
popd


#upx
git clone --depth=1 https://github.com/kuoruan/openwrt-upx.git /workdir/openwrt/staging_dir/host/bin/upx
