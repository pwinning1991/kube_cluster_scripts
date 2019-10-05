#!/usr/bin/env bash

swapoff -a

cat << EOF > /etc/yum.repos.d/kuberentes.reps
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kuberneted-el1-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
exlcude=kube*
EOF

setenforce 0

yum install -y kubelet kubeadm kubectl kubernetes-cni --disableexcludes=kubernetes

systemctl start kubelet && systemctl enable kubelet

cat <<EOF> /etc/sysctl.d/k8s.conf
met.bridge.bridge-nf-call-ip6tables = 1
met.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


