#!/bin/sh

#---- System update ----
apt update -qq && 
apt upgrade -y -qq && 
#-----------------------

#-------------- Nodejs ---------------------------------------------
apt install -y curl
# curl -sL https://deb.nodesource.com/setup_6.x | bash - &&
apt install -y --force-yes -qq build-essential make cmake u-boot-tools bc file wget &&
#-------------------------------------------------------------------

#----------- Toolchains --------------------------------------------
mkdir -p /opt/toolchains /var/www/html && 
cd /opt/toolchains && 
tar -xf ${OLDPWD}/toolchains/x86_64-buildroot-linux-uclibc-gcc.tar.gz && 
cd $OLDPWD
#-------------------------------------------------------------------
