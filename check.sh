#!/bin/bash

echo "file-max: `ulimit -Hn`"

echo `cat /etc/sysconfig/selinux |grep =disabled`

echo "firewalld: `systemctl status firewalld | grep active | awk -F ':' '{print $2 }'`"

read -r -p "Are You want to reboot? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY])
		reboot
		;;

    [nN][oO]|[nN])
		echo "ok, You can go on doing what you want..."
       	;;

    *)
		echo "Invalid input..."
		exit 1
		;;
esac
