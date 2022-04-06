#!/bin/bash
#=================================================
# File name: hook-feeds.sh
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================

# Clone Lean's feeds
mkdir customfeeds
git clone --depth=1 https://github.com/coolsnowwolf/packages customfeeds/packages
git clone --depth=1 https://github.com/coolsnowwolf/luci customfeeds/luci

# Clone ImmortalWrt's feeds
pushd customfeeds
mkdir temp
git clone --depth=1 https://github.com/immortalwrt/packages -b openwrt-18.06 temp/packages
git clone --depth=1 https://github.com/immortalwrt/luci -b openwrt-18.06-k5.4 temp/luci


# Replace coolsnowwolf/lede watchcat and luci-app-watchcat with immortalwrt source
rm -rf packages/utils/watchcat
rm -rf luci/applications/luci-app-watchcat
cp -r temp/luci/applications/luci-app-watchcat luci/applications/luci-app-watchcat
cp -r temp/packages/utils/watchcat packages/utils/watchcat

# Replace coolsnowwolf/lede php7 with immortalwrt source
#rm -rf packages/lang/php7
#cp -r temp/packages/lang/php7 packages/lang/php7

# Replace coolsnowwolf/lede perl with immortalwrt source
rm -rf packages/lang/perl
cp -r temp/packages/lang/perl packages/lang/perl

# Add tmate
cp -r temp/packages/net/tmate packages/net/tmate
cp -r temp/packages/libs/msgpack-c packages/libs/msgpack-c

# Replace https-dns-proxy with immortalwrt source
rm -rf packages/net/https-dns-proxy
cp -r temp/packages/net/https-dns-proxy packages/net/https-dns-proxy

# Add minieap and luci-proto-minieap
#cp -r temp/packages/net/minieap packages/net/minieap
#cp -r temp/luci/protocols/luci-proto-minieap luci/protocols/luci-proto-minieap

# Add luci-app-ramfree
cp -r temp/luci/applications/luci-app-ramfree luci/applications/luci-app-ramfree

# Add luci-theme-darkmatter
cp -r temp/luci/themes/luci-theme-darkmatter luci/themes/luci-theme-darkmatter


# Clearing temp directory
rm -rf temp
popd

# Set to local feeds
pushd customfeeds/packages
export packages_feed="$(pwd)"
popd
pushd customfeeds/luci
export luci_feed="$(pwd)"
popd
sed -i '/src-git packages/d' feeds.conf.default
echo "src-link packages $packages_feed" >> feeds.conf.default
sed -i '/src-git luci/d' feeds.conf.default
echo "src-link luci $luci_feed" >> feeds.conf.default

# Update feeds
#./scripts/feeds update -a
#./scripts/feeds install -a
