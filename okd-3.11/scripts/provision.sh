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

Host master
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host node1
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host node2
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
no_proxy=.okd.vm,192.168.56.100,192.168.56.101,192.168.56.102,.cluster.local,.svc,localhost,127.0.0.1,172.30.0.1,172.17.0.1
EOF
echo "Provisioning: Setup proxy"

# Setup static resolve
cat << EOF >> /etc/hosts

192.168.56.100 master.okd.vm master
192.168.56.101 node1.okd.vm node1
192.168.56.102 node2.okd.vm node2
EOF
echo "Provisioning: Setup static resolve"

# Install base packages
yum -y install vim wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct
yum update
echo "Provisioning: Install base packages"

# Install Ansible. To use EPEL as a package source for Ansible
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible pyOpenSSL
echo "Provisioning: Install Ansible"

# Install Docker 1.13
yum -y install docker-1.13.1
rpm -V docker-1.13.1
systemctl enable docker
systemctl start docker
systemctl is-active docker
docker version
echo "Provisioning: Install Docker 1.13"

# ssh root@master.okd.vm
# git clone https://github.com/openshift/openshift-ansible
# cd openshift-ansible
# git checkout release-3.11
# vim roles/etcd/defaults/main.yaml +68
# etcd_ip: "{{ etcd_ip }}"
# cp /vagrant/scripts/inventory hosts
# ansible-playbook -vv -i hosts playbooks/prerequisites.yml
# ansible-playbook -vv -i hosts playbooks/deploy_cluster.yml

docker pull openshift/origin-pod:v3.11
docker pull openshift/origin-node:v3.11
docker pull openshift/origin-control-plane:v3.11
docker pull quay.io/coreos/etcd:v3.2.28
docker images

# ansible-playbook -vv -i hosts playbooks/adhoc/uninstall.yml

echo 'Provisioning: Done'
