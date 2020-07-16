# Vagrantfile to setup Jenkins on CentOS 7
This Vagrantfile will provision a Jenkins server.

## Quick start
1. Clone this repository
```bash
git clone https://github.com/wkshi/vagrant-projects.git
```
2. Change into the `vagrant-projects/jenkins` folder
```bash
cd vagrant-projects/jenkins
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
6. Visit `http://jenkins.okd.vm:8080`

## Configuration
- Destroy vagrant instances
```bash
vagrant destroy -f
```

## Feedback
Please provide feedback of any kind via Github issues on this repository.
