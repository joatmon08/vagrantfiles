#!/usr/bin/env bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

POD_NETWORK_CIDR=$1
OUTPUT_FILE="/tmp/join.sh"

TARGET_FILE="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
NODE_IP=$(ip addr show eth1 | grep -i 'inet.*eth1' | cut -d ' ' -f 6 | cut -d '/' -f 1)

kubeadm init --apiserver-advertise-address ${NODE_IP} --pod-network-cidr ${POD_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "[Service]
Environment=\"KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf\"
Environment=\"KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true\"
Environment=\"KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin\"
Environment=\"KUBELET_DNS_ARGS=--cluster-dns=10.96.0.10 --cluster-domain=cluster.local\"
Environment=\"KUBELET_AUTHZ_ARGS=--authorization-mode=Webhook --client-ca-file=/etc/kubernetes/pki/ca.crt\"
Environment=\"KUBELET_CADVISOR_ARGS=--cadvisor-port=0\"
Environment=\"KUBELET_CGROUP_ARGS=--cgroup-driver=systemd\"
Environment=\"KUBELET_CERTIFICATE_ARGS=--rotate-certificates=true --cert-dir=/var/lib/kubelet/pki\"
Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}\"
ExecStart=
ExecStart=/usr/bin/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_SYSTEM_PODS_ARGS \$KUBELET_NETWORK_ARGS \$KUBELET_DNS_ARGS \$KUBELET_AUTHZ_ARGS \$KUBELET_CADVISOR_ARGS \$KUBELET_CGROUP_ARGS \$KUBELET_CERTIFICATE_ARGS \$KUBELET_EXTRA_ARGS" > ${TARGET_FILE}

systemctl daemon-reload
systemctl restart kubelet

kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

chmod 644 /etc/kubernetes/admin.conf
