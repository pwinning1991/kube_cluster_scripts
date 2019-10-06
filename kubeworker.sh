#!/usr/bin/env bash

#turn swapoff
swapoff -a
sed -e '/^\/root\/swap s/^#*/#/' /etc/fstab

#add kube repo
cat <<EOF> /etc/yum.repos.d/kuberenetes.repos
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kuberneted-el1-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
exlcude=kube*
EOF

#set selinux to diabled on all reboots
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

#install and enable kube pacakges
yum install -y kubelet-1.11.3 kubeadm-1.11.3 kubectl-1.11.3 kubernetes-cni-0.6.0 --disableexcludes=kubernetes

systemctl start kubelet && systemctl enable kubelet

#install docker
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl start docker && systemctl enable docker
usermod -a -G docker $(whoami)

#set kernel parameters 
cat <<EOF> /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#reload kernel parameters
sysctl --system

echo "What is the master ip address"
read MASTERIP

echo "What is the token to join?"
read token

echo "What is the sha256 of the cert?"
read sha256

#join kube cluster command
kubeadm join $MASTERIP:6443 --token $token --discovery-ca-cert-hash sha256:$sha256
