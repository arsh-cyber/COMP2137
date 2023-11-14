#!/bin/bash

#tokens
ip=$(hostname -i)
defroute=$(ip route | grep default | awk '{print $3}')


#/////////////////////////           1 Network address Changing                 /////////////////////////////////
echo $ip
cd /etc/netplan/
 #to change ip address
sed -i "s/$ip/192.168.16.21/g" $(ls *.yaml)
sed -i "s/$ip/192.168.16.21/g" /etc/hosts
 #to change  gateway
sed -i "s/$defroute/192.168.16.1/g" $(ls *.yaml)

#////////////////////      2 Install the required software          ////////////////////
apt update && apt install -y openssh-server apache2 squid

# Configure OpenSSH to allow SSH key authentication and disallow password authentication
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
service ssh restart

# Configure Apache2 to listen for HTTP on port 80 and HTTPS on port 443
a2enmod ssl
a2ensite default-ssl
service apache2 restart

# Configure Squid to listen on port 3128
sed -i 's/http_port 3128/http_port 3128/g' /etc/squid/squid.conf
service squid restart
systemctl restart apache2
systemctl reload apache2

#//////////////////////        3 firewall rules          /////////////////

if ufw status | awk '{if ($2=="inactive")
output = system("echo 'y' | ufw enable")
print output}'; then echo "firewall activated"
else echo "///////////////      firewall is already activated         /////////////"
fi
# Add rules to allow the specified services on their typical ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3128/tcp
sudo ufw reload
