#!/bin/bash

function isactive {
  if systemctl is-active "$@" >/dev/null 2>&1; then
    echo "$@ IS ON"
  else
    systemctl start "$@"
    systemctl enable "$@"
  fi
}

echo "=== INSTALLING DEPENDENCIES ==="
yum -y update >/dev/null 2>&1 && yum -y upgrade >/dev/null 2>&1
yum -y install git >/dev/null 2>&1

echo "=== GETTING IP ADDRESS ==="
ip=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`

echo "=== INSTALLING APACHE ==="
yum -y install httpd >/dev/null 2>&1

echo "=== GENERATING APACHE CONFIG ==="
echo $'<Location "/server-status">
    SetHandler server-status
    Allow from ${ip}
</Location>'  >> /etc/httpd/conf/httpd.conf

echo "=== STARTING APACHE ==="
isactive "httpd"

echo "=== CHECKING APACHE SERVER IS SERVING ==="
curl http://localhost/server-status >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "FAILED TO START APACHE SERVER"
    exit 1
fi

echo "=== DOWNLOADING GOLANG ==="
output=`curl -LO https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz >/dev/null 2>&1`
if [ $? -ne 0 ]; then
    echo "FAILED TO DOWNLOAD GOLANG ${output}"
    exit 1
fi

echo "=== UNTARRING GOLANG ==="
tar -C /usr/local -xvzf go1.7.4.linux-amd64.tar.gz >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "FAILED TO UNTAR GOLANG"
    exit 1
fi

echo "=== SETTING GOLANG ENVIRONMENT ==="
echo $'export PATH=$PATH:/usr/local/go/bin'  > /etc/profile.d/path.sh

echo $'export GOBIN="$HOME/projects/bin"
export GOPATH="$HOME/projects"'  >> ~/.bash_profile

source /etc/profile && source ~/.bash_profile

echo "=== GETTING APACHE EXPORTER ==="
output=`go get github.com/neezgee/apache_exporter`
if [ $? -ne 0 ]; then
    echo "FAILED TO GET APACHE EXPORTER : ${output}"
    exit 1
fi

echo "=== SETTING APACHE EXPORTER ==="
echo $'[Unit]
Description=Prometheus Apache Exporter
After=httpd.service

[Service]
ExecStart=/usr/bin/sh -c ~/projects/bin/apache_exporter

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/apache_exporter.service

echo "=== STARTING APACHE EXPORTER ==="
isactive "apache_exporter"

echo "=== CHECKING APACHE EXPORTER IS SERVING ==="
curl http://localhost:9117/metrics >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "FAILED TO START APACHE EXPORTER"
    exit 1
fi