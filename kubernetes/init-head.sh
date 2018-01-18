#!/usr/bin/env bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

POD_NETWORK_CIDR=$1
OUTPUT_FILE="/tmp/join.sh"

NODE_IP=$(ip addr show eth1 | grep -i 'inet.*eth1' | cut -d ' ' -f 6 | cut -d '/' -f 1)

kubeadm init --apiserver-advertise-address ${NODE_IP} --pod-network-cidr ${POD_NETWORK_CIDR} | grep "kubeadm join" > ${OUTPUT_FILE}
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

chmod 644 /etc/kubernetes/admin.conf
