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
yum install -y kubelet kubeadm kubectl kubernetes-cni --disableexcludes=kubernetes
systemctl start kubelet && systemctl enable kubelet

#set kernel parameters 
cat <<EOF> /etc/sysctl.d/k8s.conf
met.bridge.bridge-nf-call-ip6tables = 1
met.bridge.bridge-nf-call-iptables = 1
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
