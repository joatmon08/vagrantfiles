# OVS-Docker-CentOS7 Vagrantfile
This Vagrantfile sets up Open vSwitch and Docker on a CentOS host for
Virtualbox. Use this for testing purposes only.

## Dependency Information
* Virtualbox 5.1.24
* Vagrant 2.0.3
* Ruby 2.5.0
* Bundler 1.16.1

## Vagrant Box Information
See `test_box.rb` for versioning information.

## Usage
For more information about Vagrant usage, see 
[Vagrant's documentation](https://www.vagrantup.com/docs/)
* Download Vagrantfile to a directory, navigate to inside
the directory
* Download the bootstrap shell script, the Vagrantfile
needs it to provision Open vSwitch and other components.
* Run the box.
```
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'centos/7'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'centos/7' is up to date...
==> default: Setting the name of the VM: openvswitch
==> default: Fixed port collision for 22 => 2222. Now on port 2200.
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
...
==> default: Complete!
==> default: === INSTALLING OVS ===
==> default: === CHECKING OVS VERSION ===
==> default: === TURNING ON OVS ===
==> default: Created symlink from /etc/systemd/system/multi-user.target.wants/openvswitch.service to /usr/lib/systemd/system/openvswitch.service.
==> default: === INSTALLING DOCKER ===
==> default: warning: /var/cache/yum/x86_64/7/dockerrepo/packages/docker-engine-selinux-1.12.5-1.el7.centos.noarch.rpm: Header V4 RSA/SHA512 Signature, key ID 2c52609d: NOKEY
==> default: Importing GPG key 0x2C52609D:
==> default:  Userid     : "Docker Release Tool (releasedocker) <docker@docker.com>"
==> default:  Fingerprint: 5811 8e89 f3a9 1289 7c07 0adb f762 2157 2c52 609d
==> default:  From       : https://yum.dockerproject.org/gpg
==> default: Non-fatal POSTIN scriptlet failure in rpm package docker-engine-selinux-1.12.5-1.el7.centos.noarch
==> default: === TURNING ON DOCKER ===
==> default: === CHECKING DOCKER DAEMON ===
==> default: Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service.
==> default: === BOOTSTRAP COMPLETED SUCCESSFULLY! ===
```
* To SSH into the box, use `$ vagrant ssh`.
* To destroy the box, use `$ vagrant destroy`.

## Test
There are tests under `test_box.rb` that check if the box conforms to
versioning expected. They should be run separately.

### Pre-Requisites
* Ruby
* Bundler
* Inspec

### Run
1. Install the required gems.
    ```
    bundle install
    ```
2. Run Inspec to run the tests.
    ```
    inspec exec test_box.rb -t ssh://vagrant@127.0.0.1:2222 -i $(vagrant ssh-config | grep -m 1 IdentityFile | cut -d ' ' -f 4)
    ```