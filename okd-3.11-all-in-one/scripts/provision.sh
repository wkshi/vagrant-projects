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

Host dev
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
no_proxy=.okd.vm,192.168.56.110,.cluster.local,.svc,localhost,127.0.0.1,172.30.0.1,172.17.0.1
EOF
echo "Provisioning: Setup proxy"

# Setup static resolve
cat << EOF >> /etc/hosts

192.168.56.110 dev.okd.vm dev
EOF
echo "Provisioning: Setup static resolve"

# Install base packages
yum -y install vim wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct
yum update
echo "Provisioning: Install base packages"

# Install Docker 1.13
yum -y install docker-1.13.1
rpm -V docker-1.13.1
systemctl enable docker
systemctl start docker
systemctl is-active docker
docker version
echo "Provisioning: Install Docker 1.13"

# Prepare docker images
docker pull docker.io/openshift/origin-node:v3.11
docker pull docker.io/openshift/origin-control-plane:v3.11
docker pull docker.io/openshift/origin-haproxy-router:v3.11
docker pull docker.io/openshift/origin-deployer:v3.11
docker pull docker.io/openshift/origin-hyperkube:v3.11
docker pull docker.io/openshift/origin-cli:v3.11
docker pull docker.io/openshift/origin-hypershift:v3.11
docker pull docker.io/openshift/origin-pod:v3.11
docker pull docker.io/openshift/origin-docker-registry:v3.11
docker pull docker.io/openshift/origin-web-console:v3.11
docker pull docker.io/openshift/origin-service-serving-cert-signer:v3.11
docker images
echo "Provisioning: Prepare docker images"

# Install client tools
wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
tar -xvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
cp ./openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin/
cp ./openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/kubectl /usr/local/bin/
chmod +x /usr/local/bin/oc
chmod +x /usr/local/bin/kubectl
echo "Provisioning: Install client tools"

# Add unsecure registry
cat << EOF > /etc/docker/daemon.json
{
  "insecure-registries" : ["172.30.0.0/16"]
}
EOF
systemctl restart docker
echo "Provisioning: Add unsecure registry"

# oc cluster up --public-hostname=dev.okd.vm

echo 'Provisioning: Done'
