# Vagrantfile to setup OKD 3.11 Cluster on CentOS 7
This Vagrantfile will provision a OKD 3.11 cluster with one master and 2 nodes.

## Prerequisites
1. Install [libvirt/KVM]()
2. Install [Vagrant](https://vagrantup.com/)

## Quick start
1. Clone this repository
```bash
git clone https://github.com/wkshi/vagrant-projects.git
```
2. Change into the `vagrant-projects/okd-3.11` folder
```bash
cd vagrant-projects/okd-3.11
```
4. Update `scripts/custom_vars.sh` according to example script `scripts/custom_vars.sh.example`
```bash
#!/bin/bash
export HTTP_PROXY=<Your http proxy server>
export HTTPS_PROXY=<Your https proxy server>
export SSH_PUBLIC_KEYS=$(cat << EOF
<Your ssh id_rsa public key>
EOF
)
```
5. Launch vagrant instances
```bash
time ( vagrant up master; vagrant up node{1,2} )
```
6. Within the `master.okd.vm`, execute installation as `root` user:
```bash
ssh root@master.okd.vm
git clone https://github.com/openshift/openshift-ansible
cd openshift-ansible
git checkout release-3.11
vim roles/etcd/defaults/main.yaml +68
# Update line 68 as below
# etcd_ip: "{{ etcd_ip }}"
cp /vagrant/scripts/inventory hosts
ansible-playbook -vv -i hosts playbooks/prerequisites.yml
ansible-playbook -vv -i hosts playbooks/deploy_cluster.yml
```

## Configuration
- Uninstall cluster
```bash
ssh root@master.okd.vm
ansible-playbook -vv -i hosts playbooks/adhoc/uninstall.yml
```
- Destroy vagrant instances
```bash
vagrant destroy -f
```

## Feedback
Please provide feedback of any kind via Github issues on this repository.
