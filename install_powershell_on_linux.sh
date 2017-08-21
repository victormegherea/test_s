#!/bin/bash
set -e 
# Make sure only root can run script
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"  

LIBCU_URL="http://launchpadlibrarian.net/201330288/libicu52_52.1-8_amd64.deb"
POWERSHELL_BETA_V2_URL="https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.2/powershell_6.0.0-beta.2-1ubuntu1.16.04.1_amd64.deb"

function install_omi_server {
    apt-get install -y omi  omi-psrp-server
    sed  -i -e "s/\(httpport=\).*/\15985/; s/\(httpsport=\).*/\15986/" /etc/opt/omi/conf/omiserver.conf
    /opt/omi/bin/omiserver -s
    /opt/omi/bin/omiserver -d
    apt-get update -y
}

function install_dependecies {
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    curl https://packages.microsoft.com/config/ubuntu/14.04/prod.list | tee /etc/apt/sources.list.d/microsoft.list
    wget "${LIBCU_URL}"
    tmp_libcu=$(basename "$LIBCU_URL")   
    dpkg -i $tmp_libcu
    rm $tmp_libcu
    apt-get update -y 
}

function install_beta_powershell {
    apt-get install -y powershell
    install_omi_server
    apt-get update -y
    apt-get remove -y powershell
    wget "${POWERSHELL_BETA_V2_URL}" 
    tmp_betapack=$(basename "$POWERSHELL_BETA_V2_URL")
    dpkg -i $tmp_betapack
    rm $tmp_betapack
    apt-get -y update
}

function main {
   install_dependecies
   install_beta_powershell
}

main 
