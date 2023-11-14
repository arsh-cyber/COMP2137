ss#!/bin/bash

# Set the default shell for all users
export DEFAULT_SHELL="/bin/bash"

# Create the user accounts
useradd -m -s $DEFAULT_SHELL dennis
useradd -m -s $DEFAULT_SHELL aubrey
useradd -m -s $DEFAULT_SHELL captain
useradd -m -s $DEFAULT_SHELL snibbles
useradd -m -s $DEFAULT_SHELL brownie
useradd -m -s $DEFAULT_SHELL scooter
useradd -m -s $DEFAULT_SHELL sandy
useradd -m -s $DEFAULT_SHELL perrier
useradd -m -s $DEFAULT_SHELL cindy
useradd -m -s $DEFAULT_SHELL tiger
useradd -m -s $DEFAULT_SHELL yoda

# Add the specified public key to the `authorized_keys` file for the `dennis` user
cat >> /home/dennis/.ssh/authorized_keys <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm
EOF

# Generate SSH keys for all users
for user in dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
  ssh-keygen -t rsa -f /home/$user/.ssh/id_rsa -N ''
  ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -N ''
  mkdir -p /home/$user/.ssh
  # Add the user's public keys to their authorized_keys file
  cat >> /home/$user/.ssh/authorized_keys<<EOF
$(ssh-keygen -f /home/$user/.ssh/id_rsa -y)
$(ssh-keygen -f /home/$user/.ssh/id_ed25519 -y)
EOF
done

# Grant the `dennis` user sudo access
usermod -aG sudo dennis
