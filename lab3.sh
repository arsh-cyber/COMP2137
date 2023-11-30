#!/bin/bash

# Update the hosts files
echo "172.16.1.3 loghost" | sudo tee -a /etc/hosts
echo "172.16.1.4 webhost" | sudo tee -a /etc/hosts
# copy ssh public key
ssh-copy-id -i ~/.ssh/id_rsa.pub remoteadmin@server1-mgmt
ssh-copy-id -i ~/.ssh/id_rsa.pub remoteadmin@server2-mgmt

cat>server1.sh<<EOF
# Configure remoteadmin@server1-mgmt
hostnamectl set-hostname loghost
sed -i 's/server1/loghost/g' /etc/hosts
echo "172.16.1.4 webhost" | sudo tee -a /etc/hosts
sed -i 's/172.16.1.10/172.16.1.3/' /etc/netplan/50-cloud-init.yaml
netplan apply
apt-get install ufw -y
echo 'y' | ufw enable
sudo ufw allow from 172.16.1.0/24 to any port 514 proto udp
sed -i 's/#module(load="imudp")/module(load="imudp")/' /etc/rsyslog.conf
sed -i 's/#input(type="imudp" port="514")/input(type="imudp" port="514")/' /etc/rsyslog.conf
systemctl restart rsyslog
EOF
scp server1.sh remoteadmin@server1-mgmt:
ssh remoteadmin@server1-mgmt bash server1.sh 1> /dev/null

cat>server2.sh<<EOF
# Configure remoteadmin@server2-mgmt
hostnamectl set-hostname webhost
sed -i 's/server2/webhost/g' /etc/hosts
echo "172.16.1.3 loghost" | tee -a /etc/hosts
sed -i 's/172.16.1.11/172.16.1.4/' /etc/netplan/50-cloud-init.yaml
netplan apply
apt-get install ufw -y
echo 'y' | ufw enable
ufw allow from any to any port 80 proto tcp
apt-get install apache2 -y
echo "*.* @loghost" | tee -a /etc/rsyslog.conf
EOF
scp server2.sh remoteadmin@server2-mgmt:
ssh remoteadmin@server1-mgmt bash server2.sh 1>/dev/null


# Verify rsyslog configuration on loghost
ssh remoteadmin@server1 grep webhost /var/log/syslog


echo "End of script"

