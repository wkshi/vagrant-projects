#!/bin/bash

echo 'Provisioning: Started up'

# Load custom vars
if [ -f /vagrant/scripts/custom_vars.sh ]; then
    source /vagrant/scripts/custom_vars.sh
fi
echo "Provisioning: Load custom vars"

# Copy .ssh directory from host
if [ -d /root/.ssh ]; then
    rm -fr /root/.ssh
fi
cp -vr /.ssh /root/
echo "Provisioning: Copy .ssh directory from host"

# Inject custom ssh public key
# Update your custom ssh public keys in scripts/custom_var.sh file
echo "${SSH_PUBLIC_KEYS}" >> /root/.ssh/authorized_keys
chmod 700 /root/.ssh/
chown 0:0 /root/.ssh/*
chmod 600 /root/.ssh/*
echo "Provisioning: Inject custom ssh public key"

# Custom ssh configure
cat << EOF >> /root/.ssh/config
Host *.okd.vm
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host jenkins
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
echo "Provisioning: Inject custom ssh configure"

# Restore SELinux
restorecon -vvRF /root/.ssh/
echo "Provisioning: Restore SELinux"

# Turn on root login feature
sed -i "/PermitRootLogin yes/s/#//" /etc/ssh/sshd_config
systemctl restart sshd
echo "Provisioning: Turn on root login"

# Fix locale warning
echo LANG=en_US.utf-8 >> /etc/environment
echo LC_ALL=en_US.utf-8 >> /etc/environment
echo "Provisioning: Fix locale warning"

# Setup proxy
# Update proxy server as your own server in scripts/custom_var.sh file
cat << EOF >> /etc/environment

http_proxy=${HTTP_PROXY}
https_proxy=${HTTPS_PROXY}
no_proxy=.okd.vm,192.168.56.50,.cluster.local,.svc,localhost,127.0.0.1,172.30.0.1,172.17.0.1
EOF
echo "Provisioning: Setup proxy"

# Setup static resolve
cat << EOF >> /etc/hosts

192.168.56.50 jenkins.okd.vm jenkins
EOF
echo "Provisioning: Setup static resolve"

# Install Jenkins
yum -y install vim wget bash-completion
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum upgrade
yum -y install jenkins java-1.8.0-openjdk-devel
echo "Provisioning: Install Jenkins"

# Setup firewall
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=jenkins
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
echo "Provisioning: Setup firewall"

# Start service
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
echo "Provisioning: Start service"

echo 'Provisioning: Done'
