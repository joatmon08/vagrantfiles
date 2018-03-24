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
yum -y update && yum -y upgrade

echo "=== INSTALLING OVS DEPENDENCIES ==="
yum -y install make gcc openssl-devel autoconf automake \
rpm-build redhat-rpm-config python-devel python-six \
openssl-devel kernel-devel kernel-debug-devel libtool wget \
net-tools
if [ $? -ne 0 ]; then
    echo "FAILED TO DOWNLOAD OVS DEPENDENCIES"
    exit 1
fi

echo $'[cloud7]
name=CentOS Cloud7 Openstack
baseurl=https://cbs.centos.org/repos/cloud7-openstack-pike-release/x86_64/os/
enabled=1
gpgcheck=0'  > /etc/yum.repos.d/cloud7.repo

if isinstalled "openvswitch"; then
    echo "=== OVS IS ALREADY INSTALLED"
else
    echo "=== INSTALLING OVS ==="
    output=`yum -y install openvswitch`
    if [ $? -ne 0 ]; then
        echo "FAILED TO INSTALL OVS : ${output}"
        exit 1
    fi
fi

echo "=== CHECKING OVS VERSION ==="
output=`ovs-vsctl --version`
if [ $? -ne 0 ]; then
    echo "NEED TO CHANGE PATH FOR OVS : ${output}"
    exit 1
fi

echo "=== TURNING ON OVS ==="
isactive "openvswitch"

systemctl enable openvswitch

echo $'[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg' > /etc/yum.repos.d/docker.repo

if isinstalled "docker"; then
    echo "=== DOCKER IS ALREADY INSTALLED"
else
    echo "=== INSTALLING DOCKER ==="
    output=`yum -y install docker-engine`
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