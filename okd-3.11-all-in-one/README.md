# Vagrantfile to setup OKD 3.11 all in one cluster on CentOS 7
This Vagrantfile will provision a OKD 3.11 all in one cluster.

## Quick start
1. Clone this repository
```bash
git clone https://github.com/wkshi/vagrant-projects.git
```
2. Change into the `vagrant-projects/okd-3.11-all-in-one` folder
```bash
cd vagrant-projects/okd-3.11-all-in-one
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
time vagrant up
```
6. Within the `dev.okd.vm`, execute installation as `root` user:
```bash
ssh root@master.okd.vm
oc cluster up --public-hostname=dev.okd.vm
```

## Configuration
- Uninstall cluster
```bash
ssh root@master.okd.vm
oc cluster down
```
- Destroy vagrant instances
```bash
vagrant destroy -f
```

## Feedback
Please provide feedback of any kind via Github issues on this repository.
