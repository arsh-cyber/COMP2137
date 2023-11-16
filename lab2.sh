#!/bin/bash

#tokens
ip=$(hostname -I | awk '{print $2}')
defaultrt=$(ip route | grep default | awk '{print $3}')


#/////////////////////////           1 Network address Changing                 /////////////////////////////////

echo "Changing IP address, Domain name, default gateway"
cd /etc/netplan/
 #to change ip address
if [ "$ip" != "192.168.16.21"  ]
  then sed -i "s/$ip/192.168.16.21/g" /etc/hosts
  sed -i "s/$ip/192.168.16.21/g" $(ls *.yaml)
  echo 'hello'
  else echo "IP address already exist"
  fi
 #to change  gateway
sed -i "s/$defaultrt/192.168.16.1/g" $(ls *.yaml)

echo "netplan Applying"
sudo netplan apply
echo "netplan Applied"


#////////////////////      2 Installing the required software          ////////////////////
softwareinstall=$(which apache2 | grep -o apache2)
echo "
///////////////////             installing required softwares       ////////////////////////  "

if [ "$softwareinstall"="apache2","squid","openssh-server" ];then
  apt update 1>/dev/null && apt install -y openssh-server apache2 squid 1>/dev/null 2> /dev/null
  else echo "Software is already installed"
  fi

echo "/////////////////////         disallow password authentication for Open SSH      ///////////////////////////"
if ! $(grep -q "PasswordAuthentication no" /etc/ssh/sshd_config);then
  sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config 1>/dev/null 2>/dev/null
    service ssh restart
  else
    echo "Password Authentication id already disabled"
  fi
  

# Configure Apache2 to listen for HTTP on port 80 and HTTPS on port 443
a2enmod ssl
a2ensite default-ssl
service apache2 restart

# Configure Squid to listen on port 3128
sed -i 's/#http_port 3128/http_port 3128/g' /etc/squid/squid.conf
echo "///////////////////////////////                Please wait for 30s to restart apache server           ////////////////////////////"
service squid restart 1>/dev/null
systemctl restart apache2 1>/dev/null
systemctl reload apache2 1>/dev/null

#//////////////////////        3 firewall rules          /////////////////

if ufw status | awk '{if ($2=="inactive")
output = system("echo 'y' | ufw enable 1>/dev/null")
print output}'; then echo "firewall activated"
else echo "///////////////      firewall is already activated         /////////////"
fi
echo "/////////////////         Adding new firewall rules         ///////////////"
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3128/tcp
sudo ufw reload

#/////////////////////////      4 creating users         ///////////////////////////

# Set the default shell for all users
export DEFAULT_SHELL="/bin/bash" 1>/dev/null

# Create the user accounts
useradd -m -s $DEFAULT_SHELL dennis 1>/dev/null
useradd -m -s $DEFAULT_SHELL aubrey 1>/dev/null
useradd -m -s $DEFAULT_SHELL captain 1>/dev/null
useradd -m -s $DEFAULT_SHELL snibbles 1>/dev/null
useradd -m -s $DEFAULT_SHELL brownie 1>/dev/null
useradd -m -s $DEFAULT_SHELL scooter 1>/dev/null
useradd -m -s $DEFAULT_SHELL sandy 1>/dev/null
useradd -m -s $DEFAULT_SHELL perrier 1>/dev/null
useradd -m -s $DEFAULT_SHELL cindy 1>/dev/null
useradd -m -s $DEFAULT_SHELL tiger 1>/dev/null
useradd -m -s $DEFAULT_SHELL yoda 1>/dev/null

# Add the specified public key to the `keys.pub` file for the `dennis` user
cat >> /home/dennis/.ssh/keys.pub <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm
EOF

echo "///////////////////          Generating ssh-key Gen for all Users           /////////////////////////// "
for user in dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
  mkdir -p /home/$user/.ssh
  echo "y" | ssh-keygen -t rsa -f /home/$user/.ssh/id_rsa -N '' 1>/dev/null
  echo "y" | ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -N '' 1>/dev/null
  # Add the user's public keys to their authorized_keys file

  $(echo "y" | ssh-keygen -f /home/$user/.ssh/id_rsa -y) 1>/dev/null
  $(echo "y" | ssh-keygen -f /home/$user/.ssh/id_ed25519 -y) 1>/dev/null
  done


echo""
echo "Granting Sudo Permission to dennis user"
usermod -aG sudo dennis 
