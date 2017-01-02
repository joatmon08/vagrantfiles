# Prometheus-Apache Exporter Vagrantfile
This Vagrantfile sets up Prometheus and the Apache Exporter on a CentOS host for
Virtualbox. Use this for testing purposes only.

## Dependency Information
* Virtualbox 5.1.12r112440
* Vagrant 1.9.1

## Vagrant Box Information
* CentOS 7 (kernel 3.10.0-514.2.2.el7.x86_64)
* Golang 1.7.4
* [Apache Exporter for Prometheus](https://github.com/neezgee/apache_exporter)
* Apache2 Web Server

## Usage
For more information about Vagrant usage, see 
[Vagrant's documentation](https://www.vagrantup.com/docs/)
* Download Vagrantfile to a directory, navigate to inside
the directory
* Download the bootstrap shell script, the Vagrantfile
needs it to provision the Apache Exporter.
* Run the box. The Vagrantfile forwards the Apache Exporter for Prometheus
on host port 9117 and the Apache server-status page on host port 8080.
```
$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'centos/7'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'centos/7' is up to date...
==> default: Setting the name of the VM: prometheus-httpd
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 80 (guest) => 8080 (host) (adapter 1)
    default: 9117 (guest) => 9117 (host) (adapter 1)
    default: 22 (guest) => 2222 (host) (adapter 1)
...
==> default: === INSTALLING APACHE ===
==> default: === GENERATING APACHE CONFIG ===
==> default: === STARTING APACHE ===
==> default: === CHECKING APACHE SERVER IS SERVING ===
==> default: === DOWNLOADING GOLANG ===
==> default: === UNTARRING GOLANG ===
==> default: === SETTING GOLANG ENVIRONMENT ===
==> default: === GETTING APACHE EXPORTER ===
==> default: === SETTING APACHE EXPORTER ===
==> default: === STARTING APACHE EXPORTER ===
==> default: === CHECKING APACHE EXPORTER IS SERVING ===

```
* To SSH into the box, use `$ vagrant ssh`.
* To destroy the box, use `$ vagrant destroy`.