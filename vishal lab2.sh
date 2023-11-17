#!/bin/bash

function display_message() {
    echo "----------------------------------------"
    echo "$1"
    echo "----------------------------------------"
}

# Function to update the network configuration using netplan
function update_network_config() {
    display_message "Updating network configuration..."
    # Check if the current configuration matches the required configuration
    current_ip=$(ip -4 addr show dev eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    current_gateway=$(ip route | grep default | awk '{print $3}')
    current_dns=$(systemd-resolve --status | grep 'DNS Servers' | awk '{print $3}')
    current_search_domains=$(systemd-resolve --status | grep 'DNS Domain' | awk '{print $3}')

    if [ "$current_ip" != "192.168.16.21/24" ] || [ "$current_gateway" != "192.168.16.1" ] || [ "$current_dns" != "192.168.16.1" ] || [ "$current_search_domains" != "home.arpa localdomain" ]; then
        # Update netplan configuration
        cat <<EOF | sudo tee /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 192.168.16.21/24
      gateway4: 192.168.16.1
      nameservers:
        addresses:
          - 192.168.16.1
        search:
          - home.arpa
          - localdomain
EOF
        sudo netplan apply
        display_message "Network configuration updated successfully."
    else
        display_message "Network configuration is already correct. No changes needed."
    fi
}

# Function to install required software
function install_software() {
    display_message "Installing required software..."
    # Install openSSH server, Apache2, and Squid
    sudo apt update
    sudo apt install -y openssh-server apache2 squid
    display_message "Software installation complete."
}

# Function to configure firewall using ufw
function configure_firewall() {
    display_message "Configuring firewall..."
    # Allow SSH, HTTP, HTTPS, and Squid ports through the firewall
    sudo ufw allow 22
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw allow 3128
    sudo ufw --force enable
    display_message "Firewall configured successfully."
}

# Function to create user accounts and set up SSH keys
function create_user_accounts() {
    display_message "Creating user accounts and setting up SSH keys..."
    # Create users and configure SSH keys
    users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

    for user in "${users[@]}"; do
        sudo useradd -m -s /bin/bash "$user"
        sudo mkdir -p /home/$user/.ssh
        sudo touch /home/$user/.ssh/authorized_keys
        sudo chown -R $user:$user /home/$user/.ssh
        sudo chmod 700 /home/$user/.ssh
        sudo chmod 600 /home/$user/.ssh/authorized_keys
    done

    # Add SSH keys to authorized_keys
    sudo bash -c 'cat <<EOF > /home/dennis/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm
# Add other generated public keys for dennis here
EOF'

    display_message "User accounts and SSH keys configured successfully."
}

# Main script execution
update_network_config
install_software
configure_firewall
create_user_accounts

display_message "Script execution complete."

exit 0
