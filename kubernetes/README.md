# Kubernetes on CentOS7 Vagrantfile
This Vagrantfile stages a Kubernetes cluster on CentOS hosts for
Virtualbox. Use this for testing purposes only. To start a cluster,
use [kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)

**You will need to run the initialization
scripts on each host manually. This
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
* Update the number of workers under `NUM_WORKERS` you want in the Vagrantfile.
* Create the boxes. The master node is labeled `head`, the workers are labeled
`worker[0-n]`.
  ```
  $ vagrant up
  ```
* SSH into the head node.
  ```
  $ vagrant ssh head
  ```
* Run the following command on the head node to initialize via kubeadm,
write out the token command, and set up kube-router networking.
  ```
  $ /tmp/init-head.sh (POD CIDR)
  ```
* Retrieve the token that was generated for worker registration.
  ```
  $ less /tmp/join.sh
  kubeadm join --token REDACTED 192.168.205.10:6443 --discovery-token-ca-cert-hash REDACTED
  ```
* SSH into the worker nodes.
  ```
  $ /tmp/init-worker.sh "kubeadm join --token REDACTED 192.168.205.10:6443 --discovery-token-ca-cert-hash REDACTED
    ...
    This node has joined the cluster:
    * Certificate signing request was sent to master and a response
      was received.
    * The Kubelet was informed of the new secure connection details.
    Run 'kubectl get nodes' on the master to see this node join the cluster.
  ```

## Manually Install without Init Scripts
* Run [kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm/) (or any other Kubernetes bootstrapping tool).
* Add Kubernetes networking of your choice.

You can use the `boostrap.sh` file to install all dependencies on your
own base box!

## Caveats
The Vagrantfile configures everything via the bootstrap.sh file. In the bootstrap, it stages the
Virtualbox machine for Kubernetes. This means:
* disabling swap space. See [this Github issue](https://github.com/kubernetes/kubernetes/issues/53533)
for more information.
* bridged traffic to iptables is enabled for kube-router.
* disabling SELinux, since it affects etcd on restart.

## Remotely Accessing Cluster
Transfer the admin.conf from the head node to a local file.

```
scp -P 2222 -i $(vagrant ssh-config | grep -m 1 IdentityFile | cut -d ' ' -f 4) vagrant@127.0.0.1:/etc/kubernetes/admin.conf .
```

When issuing kubectl on your local machine, be sure to specify the file or set
it as the KUBECONFIG.
```
kubectl --kubeconfig ./admin.conf get nodes

## OR ##

export KUBECONFIG=$(pwd)/admin.conf
```
