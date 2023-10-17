#!/bin/bash

#gather data from report
myuser=$USER
sysdate=$(date +%F)
systime=$(date | awk '{print $5,$6}')
myhostname=$HOSTNAME
myip=$(ip a | grep -w  inet | awk '{print$2}')
osinfo=$(hostnamectl | grep -w Operating | awk '{print $3,$4,$5}')
#hostnamectl | grep -w Kernel | awk '{print $2,$3}')
uptime=$(w | grep -w up | awk {'print $3,substr($4,1, length($4)-1)'})

#hardware information variables
cpuinfo=$(lscpu | awk -F: '/Model name/ {print $2}' | awk '{$1=$1};1')
model=$(lscpu | awk -F: '/Model:/ {print $2}' | awk '{$1=$1};1')

raminfo=$(free -m | awk 'NR==2{printf "%.2fGB", $2 / 1024}')
diskinfo=$(lsblk -d --output NAME,MODEL,SIZE | awk -F: '/s/ {print $1,$2,$3}')
vc1=$(sudo lshw -C display | awk '/vendor:/ {print $2}')
vc2=$(sudo lshw -C display | awk '/product:/ {print $2,$3,$4,$5}')


echo "
System Report generated by $myuser, $sysdate/$systime

System Information
------------------
Hostname: $myhostname
Os: $osinfo
Uptime: $uptime

Hardware Information
--------------------
cpu: $cpuinfo and Model: $model
Speed: CURRENT AND MAXIMUM CPU SPEED
Ram: $raminfo
Disk(s):
Make        Model                       Size
$diskinfo
Video: Make:$vc1 , MODEL:$vc2



"
