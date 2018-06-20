#!/bin/bash

export DOMAIN=${DOMAIN:="$(ifconfig | grep "inet 192.168" | grep -oE "192.168.[0-9]{2,4}.[0-9]{2,4}[^255]")"}

echo "* Your domain is $DOMAIN "

firewall-cmd --zone=public --add-port=8443/tcp --permanent
firewall-cmd --reload

echo "*** Firewall Set Success ***"

yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast
yum install -y --setopt=obsoletes=0 docker-ce-18.03.1.ce-1.el7.centos docker-ce-selinux-18.03.1.ce-1.el7.centos

echo "*** Docker Install Success ***"

systemctl start docker
systemctl enable docker

echo "*** Docker Start Success ***"

echo "{" >> /etc/docker/daemon.json
echo "  \"insecure-registries\": [\"172.30.0.0/16\"]" >> /etc/docker/daemon.json
echo "}" >> /etc/docker/daemon.json

echo "*** Docker Edit Daemon Success ***"

systemctl restart docker

echo "*** Docker Restart Success ***"

cd /opt
yum install -y wget
wget https://github.com/openshift/origin/releases/download/v3.9.0/openshift-origin-server-v3.9.0-191fece-linux-64bit.tar.gz
tar -zxvf openshift-origin-server-v3.9.0-191fece-linux-64bit.tar.gz
mv openshift-origin-server-v3.9.0-191fece-linux-64bit openshift

echo "*** OpenShift Setup Success ***"

echo "PATH=\$PATH:/opt/openshift" >> /etc/profile
source /etc/profile

echo "*** OpenShift Setup ENV Success ***"

oc cluster up --public-hostname=$DOMAIN