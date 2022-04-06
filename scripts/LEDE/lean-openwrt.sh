#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================

HWOSDIR="package/base-files/files"

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' $HWOSDIR/bin/config_generate

# Switch dir to package/lean
pushd package/lean

# Add luci-app-ssr-plus
git clone --depth=1 https://github.com/fw876/helloworld

# Exit from package/lean dir
popd

# Clone community packages to package/community
mkdir package/community
pushd package/community

# Add luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall
sed -i 's/ upx\/host//g' openwrt-passwall/v2ray-plugin/Makefile
grep -lr upx/host openwrt-passwall/* | xargs -t -I {} sed -i '/upx\/host/d' {}

# Add OpenClash
git clone --depth=1 -b master https://github.com/vernesong/OpenClash

# Add luci-app-wrtbwmon
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/luci-app-wrtbwmon
svn co https://github.com/sirpdboy/sirpdboy-package/trunk/wrtbwmon
rm -rf ../lean/luci-app-wrtbwmon

# Add luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config
rm -rf ../lean/luci-theme-argon

#-----------------------------------------------------------------------------

# HelmiWrt packages
git clone --depth=1 https://github.com/helmiau/helmiwrt-packages

# Add themes from kenzok8 openwrt-packages
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-atmaterial_new kenzok8/luci-theme-atmaterial_new
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-edge kenzok8/luci-theme-edge
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-ifit kenzok8/luci-theme-ifit
#svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentomato kenzok8/luci-theme-opentomato
#svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentomcat kenzok8/luci-theme-opentomcat
#svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentopd kenzok8/luci-theme-opentopd

#-----------------------------------------------------------------------------
popd

# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
sed -i '/18.06/d' zzz-default-settings
export orig_version=$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
export date_version=$(date -d "$(rdate -n -4 -p pool.ntp.org)" +'%Y-%m-%d')
sed -i "s/${orig_version}/${orig_version} ${date_version}/g" zzz-default-settings
sed -i "s/zh_cn/auto/g" zzz-default-settings
sed -i "s/uci set system.@system[0].timezone=CST-8/uci set system.@system[0].hostname=Mi4AG\nuci set system.@system[0].timezone=MYT-8/g" zzz-default-settings
sed -i "s/Shanghai/Kuala Lumpur/g" zzz-default-settings
sed -i '/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/d' /etc/shadow
echo -e "root::0:0:99999:7:::" >> /etc/shadow
popd

# Fix mt76 wireless driver
pushd package/kernel/mt76
sed -i '/mt7662u_rom_patch.bin/a\\techo mt76-usb disable_usb_sg=1 > $\(1\)\/etc\/modules.d\/mt76-usb' Makefile
popd

# Change default shell to zsh
#sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' $HWOSDIR/etc/passwd

#-----------------------------------------------------------------------------

# Add kernel build user
sed -i 's/CONFIG_KERNEL_BUILD_USER=""/CONFIG_KERNEL_BUILD_USER="gilagajet"/g' .config

# Add kernel build domain
sed -i 's/CONFIG_KERNEL_BUILD_DOMAIN=""/CONFIG_KERNEL_BUILD_DOMAIN="modem.my"/g' .config

# Update Version
#sed -i 's/Newifi D2/Mi 4A Gigabit/g' files/etc/banner
echo -e "          Built on "$(date +%Y.%m.%d)"\n -----------------------------------------------------" >> files/etc/banner
sed -i "s/OpenWrt /GilaGajet build $(TZ=UTC+8 date "+%Y.%m.%d") @ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

# Update TimeZone
sed -i 's/ntp.aliyun.com/time.google.com/g' package/base-files/files/bin/config_generate
sed -i 's/time1.cloud.tencent.com/time.cloudflare.com/g' package/base-files/files/bin/config_generate
sed -i 's/time.ustc.edu.cn/clock.sjc.he.net/g' package/base-files/files/bin/config_generate
sed -i 's/cn.pool.ntp.org/my.pool.ntp.org/g' package/base-files/files/bin/config_generate

#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
