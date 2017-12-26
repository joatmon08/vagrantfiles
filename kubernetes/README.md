# Kubernetes on CentOS7 Vagrantfile
This Vagrantfile stages a Kubernetes cluster on CentOS hosts for
Virtualbox. Use this for testing purposes only. To start a cluster,
use [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)

**You will need to run the kubeadm command manually. This
Vagrantfile does not automatically register the worker
nodes to the head node!!**

## Dependency Information
* Virtualbox
* Vagrant

## Vagrant Box Information
* CentOS 7 (kernel 3.10.0-693.2.1.el7.x86_64)
* Docker 1.12.6
* Kubernetes 1.8.4

## Usage
For more information about Vagrant usage, see
[Vagrant's documentation](https://www.vagrantup.com/docs/)
* Download Vagrantfile to a directory, navigate to inside
the directory
* Download the bootstrap shell script, the Vagrantfile
needs it to provision Open vSwitch and other components.
* Update the number of workers under NUM_WORKERS you want in the Vagrantfile.
* Create the boxes. The master node is labeled "head", the workers are labeled
worker with an integer.
* To SSH into the box, use `$ vagrant ssh <name>`.
* Run kubeadm (or any other Kubernetes bootstrapping tool).
* To destroy the setup, use `$ vagrant destroy`.

## Remote Usage
Transfer the admin.conf from the head node to a local file.

```
scp -P 2222 -i <key file> vagrant@127.0.0.1:/etc/kubernetes/admin.conf vagrant-kube.conf
```

When issuing kubectl on your local machine, be sure to specify the file.
```
kubectl --kubeconfig ./vagrant-kube.conf get nodes
```
