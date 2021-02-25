#!/bin/bash -

function isinstalled {
  if yum list installed "$@" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

function isactive {
  if systemctl is-active "$@" >/dev/null 2>&1; then
    echo "$@ IS ON"
  else
    systemctl start "$@"
  fi
}
yum update -y && yum upgrade
yum install -y subscription-manager
yum install -y make gcc openssl-devel rpm-build yum-utils wget

echo "=== INSTALLING OVS DEPENDENCIES ==="
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum install -y centos-release-openstack-ussuri
dnf config-manager --set-enabled powertools
if [ $? -ne 0 ]; then
    echo "FAILED TO DOWNLOAD OVS DEPENDENCIES"
    exit 1
fi

yum upgrade

if isinstalled "openvswitch"; then
    echo "=== OVS IS ALREADY INSTALLED"
else
    echo "=== INSTALLING OVS ==="
    output=`yum install -y libibverbs openvswitch`
    if [ $? -ne 0 ]; then
        echo "FAILED TO INSTALL OVS : ${output}"
        exit 1
    fi
fi

echo "=== TURNING ON OVS ==="
isactive "openvswitch"

systemctl enable --now openvswitch

echo "=== CHECKING OVS VERSION ==="
output=`ovs-vsctl show`
if [ $? -ne 0 ]; then
    echo "NEED TO CHANGE PATH FOR OVS : ${output}"
    exit 1
fi

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

if isinstalled "docker"; then
    echo "=== DOCKER IS ALREADY INSTALLED"
else
    echo "=== INSTALLING DOCKER ==="
    output=`yum install -y docker-ce docker-ce-cli containerd.io`
    if [ $? -ne 0 ]; then
        echo "FAILED TO INSTALL DOCKER : ${output}"
        exit 1
    fi
fi

echo "=== TURNING ON DOCKER ==="
isactive "docker"

echo "=== CHECKING DOCKER DAEMON ==="
output=`docker ps`
if [ $? -ne 0 ]; then
    echo "FAILED TO SHOW DOCKER INFORMATION : ${output}"
    exit 1
fi

systemctl enable docker

echo "=== INSTALLING OVS-DOCKER ==="
cd /usr/bin
wget https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker
if [ $? -ne 0 ]; then
    echo "FAILED TO GET OVS-DOCKER UTILITY"
    exit 1
fi
chmod a+rwx ovs-docker

echo "=== CHECKING OVS-DOCKER ==="
output=`ls /usr/bin | grep ovs-docker`
if [ -z "${output}" ]; then
    echo "FAILED TO INSTALL OVS-DOCKER"
    exit 1
fi

echo "=== BOOTSTRAP COMPLETED SUCCESSFULLY! ==="
exit 0