#!/bin/bash

#gather data from report
user=$(whoami)
sysdate=$(date +%F)
systime=$(date | awk '{print $5,$6}')
myhostname=$(hostname)
myip=$(ip a | grep -w  inet | awk '{print$2}')
osinfo=$(hostnamectl | grep -w Operating | awk '{print $3,$4,$5}')
#hostnamectl | grep -w Kernel | awk '{print $2,$3}')
uptime=$(w | grep -w up | awk {'print $3,substr($4,1,length($4)-2)'})

#hardware information variables
cpuinfo=$(lscpu | awk -F: '/Model name/ {print $2}' | awk '{$1=$1};1')
model=$(lscpu | awk -F: '/Model:/ {print $2}' | awk '{$1=$1};1')
cpuclock=$(cat /proc/cpuinfo | awk -F: '/MHz/ {print $2, "MHz";exit 1}')
cpumax=$(sudo lshw -class processor | awk -F: '/capacity/ {print $2; exit 1}')
raminfo=$(free -m | awk 'NR==2{printf "%.2fGB", $2 / 1024}')
diskinfo=$(lsblk -d --output NAME,MODEL,SIZE | awk -F: '/s/ {print $1, $3, $2}')
vc1=$(sudo lshw -C display | awk '/vendor:/ {print $2}')
vc2=$(sudo lshw -C display | awk '/product:/ {print $2,$3,$4,$5}')

#Network information Variables
fqdn=$(hostname --fqdn)
ip=$(hostname -I | awk '{print $1}')
default=$(ip route | awk '/default/ {print $3}')
dnsip=$(resolvectl status | awk '/Current DNS Server/ {print $4;exit 1}')
intmake=$(sudo lshw -c network | awk '/vendo/{print "Make:",$2,$3;exit 1}')
intmodel=$(sudo lshw -c network | awk '/product/{print "And Model:",$2,$3,$4;exit 1}')
ipcidr=$(ip add | grep inet | grep / | grep brd | awk '{print $2;exit 1}')

#system status variables
userslogin=$(users | tr " " ",")
dfspace=$(df -h | awk '// {print $4, ":"$6}')
pscount=$(ps aux | wc -l)
ldavg=$(uptime | awk '{print $8,$9,$10}')
memoryallo=$(free -h | awk '/Mem:/ {print $3}')
listnetwork=$(ss -ln | awk '{print $5}' | grep : | grep -v -e "-" -e "e" -e "w" | cut -d : -f2 | sort -n| uniq | tr "\n" ",")
ufw=$(sudo ufw status numbered)

echo "
System Report generated by $user, $sysdate/$systime

System Information
------------------
Hostname: $myhostname
Os: $osinfo
Uptime: $uptime

Hardware Information
--------------------
cpu: $cpuinfo and Model: $model
Speed: CURRENT = $cpuclock AND MAXIMUM = $cpumax
Ram: $raminfo
Disk(s):
Make        Model                       Size
$diskinfo

Video: Make:$vc1 , MODEL:$vc2

Network Information
-------------------
FQDN: $fqdn
Host Address: $ip
Gateway IP: $default
DNS Server: $dnsip

InterfaceName: $intmake $intmodel
IP Address: $ipcidr

System Status
-------------
Users Logged In: $userslogin
Disk Space: 
$dfspace
Process Count: $pscount
Load Averages: $ldavg
Memory Allocation: $memoryallo
Listening Network Ports: $listnetwork
UFW Rules: $ufw

"
