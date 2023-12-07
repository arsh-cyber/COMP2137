- name: playbook to install apache2 on target1
  hosts: targets
  remote_user: remoteadmin
  tasks:
    - name: Install Apache2
      apt:
        name: apache2
        state: present
	update_cache: yes
    - name: Enable Apache2 service
      service:
        name: apache2
        enabled: yes
        state: started
    - name: Install UFW firewall
      apt:
        name: ufw
        state: present
	update_cache: yes
    - name: Enable UFW firewall
      ufw:
        state: enabled
    - name: Allow SSH traffic
      ufw:
        rule: allow
        port: 22
        proto: tcp
    - name: Allow HTTP traffic on port 80
      ufw:
        rule: allow
        port: 80
        proto: tcp
################################################################################

- name: playbook to install mysql on target2.
  hosts: targets
  remote_user: remoteadmin
  tasks:
    - name: Install MySQL
      apt:
        name: mysql-server
        state: present
	update_cache: yes
    - name: Enable MySQL service
      service:
        name: mysql
        enabled: yes
        state: started
    - name: Install UFW firewall
      apt:
        name: ufw
        state: present
    - name: Enable UFW firewall
      ufw:
        state: enabled
    - name: Allow SSH traffic
      ufw:
        rule: allow
        port: 22
        proto: tcp
    - name: Allow MySQL traffic on port 3306
      ufw:
        rule: allow
        port: 3306
        proto: tcp
