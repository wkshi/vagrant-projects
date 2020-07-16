# vagrant-projects
A collection of Vagrant projects that provision CentOS and other software automatically, using Vagrant, an CentOS box, and shell scripts. Unless indicated otherwise, these projects work with libvirt/KVM.

## Prerequisites
All projects in this repository require Vagrant and libvirt/KVM with the vagrant-libvirt plugin.

### If using libvirt/KVM in Fedora
- Install libvirt related packages
```bash
sudo dnf install virt-manager qemu-kvm qemu-img libvirt-daemon libvirt-daemon-driver*
sudo usermode -aG libvirt <YOUR USERNAME>
sudo systemctl restart libvirtd
sudo systemctl status libvirtd
```
- Install `vagrant` and `vagrant-libvirt` plugin
```bash
sudo dnf install vagrant
sudo dnf remove vagrant-libvirt rubygem-fog-core
vagrant plugin install vagrant-libvirt
```

## Getting started
1. Clone this repository `git clone https://github.com/wkshi/vagrant-projects.git`
2. Change into the desired project folder
3. Follow the README.md instructions inside the folder

## Known issues

## Feedback
Please provide feedback of any kind via Github issues on this repository.
