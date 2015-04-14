#!/bin/bash
# Host environment: centos 6.6
#author: xuejq
#nagios dir :/home/nagios/nagios4
#blog: xuejqone.com 

current_dir=`pwd`
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: please use root to install this script!"
    exit 1
fi
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#create user
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios

mkdir 