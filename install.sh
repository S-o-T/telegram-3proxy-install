#!/bin/bash
VERSION="0.8.11"
IP=($(hostname -I))
PORT=61555
USERNAME="user"
PASS=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c14)

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use: sudo ./install.sh)" 1>&2
   exit 1
fi

apt update
apt install build-essential -y

wget https://github.com/z3APA3A/3proxy/archive/$VERSION.tar.gz
tar -zxvf $VERSION.tar.gz

cd 3proxy-$VERSION

make -f Makefile.Linux
if [[ $? -ne 0 ]]
    echo "Can not build 3proxy, aborting" 1>&2
    exit 2
fi
make install -f Makefile.Linux

cd ../
cp 3proxy.cfg /usr/local/etc/3proxy/
#mkdir /usr/local/etc/3proxy/log


echo "$USERNAME:CL:$PASS" > /usr/local/etc/3proxy/userpass
echo "socks -i$IP -e$IP -p$PORT" > /usr/local/etc/3proxy/socks.cfg

cp 3proxy.service /lib/systemd/system/
systemctl enable 3proxy.service
stsremctl start 3proxy.service

if [[ $? -ne 0 ]]
    echo "Something gone wrong... I am so sorry." 1>&2
    exit 3
fi

echo "Now you can use this settings to configure your telegram client, use connection type proxy/tcpsocks5"
echo "server: $IP"
echo "port: $PORT"
echo "username: $USERNAME"
echo "pass: $PASS"
