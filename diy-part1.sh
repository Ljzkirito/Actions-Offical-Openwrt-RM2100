#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Add a feed source
sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default
sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall' feeds.conf.default

mkdir package/diy
# 获取luci-app-ssr-plus缺失的依赖
pushd package/diy
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2
popd
# Add luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/diy/luci-theme-argon
#git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/diy/luci-app-argon-config
# 使用官方ppp 2.4.9
rm -rf package/network/services/ppp
svn co https://github.com/Ljzkirito/openwrt-packages/trunk/ppp package/network/services/ppp
# 更改时区
sed -i "s/'UTC'/'CST-8'\n\t\tset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
# 更改默认NTP服务器
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time.ustc.edu.cn/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/cn.pool.ntp.org/g' package/base-files/files/bin/config_generate
# version.mk: use tencent's opkg mirror
sed -i 's/downloads.openwrt.org/mirrors.cloud.tencent.com/g' include/version.mk
sed -i 's/downloads.openwrt.org/mirrors.cloud.tencent.com/g' package/base-files/image-config.in
# Change dnsmasq to dnsmasq-full
sed -i 's/dnsmasq/dnsmasq-full/g' include/target.mk
# target.mk: use libustream-openssl instead of libustream-wolfssl
#sed -i 's/libustream-wolfssl/libustream-openssl/g' include/target.mk
# base-files: upgrade: use zcat command provided by busybox
sed -i 's/"zcat/"busybox zcat/g' package/base-files/files/lib/upgrade/common.sh
# toolchain: optimize for performance instead of size
sed -i 's/CPU_CFLAGS = -Os -pipe/CPU_CFLAGS = -O2 -pipe/g' include/target.mk
# kernel: set default nf_conntrack_max to 65536
sed -i 's/nf_conntrack_max=16384/nf_conntrack_max=65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf