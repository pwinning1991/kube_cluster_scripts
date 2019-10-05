#!/usr/bin/env bash

#turn swapoff
swapoff -a
sed -e '/^\/root\/swap/ s/^#*/#/' /etc/fstab

#add kube repo
cat <<EOF> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

#set selinux to diabled on all reboots
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0

#install and enable kube pacakges
yum install -y kubelet kubeadm kubectl kubernetes-cni --disableexcludes=kubernetes
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

#create kubeadm config file
#cat <<EOF> kube-config.yml
#apiVersion: kubeadm.k8s.io/v1alpha1
#kind:
#kubernetesVersion: "v1.11.3"
#networking:
#  podSubnet: 10.244.0.0/16
#apiServerExtraArgs:
#  service-node-port-range: 8000-31274
#EOF

#intilize kube dir:w
kubeadm init --pod-network-cidr=10.244.0.0/16 --service-node-port-range=8000-31274

#make howe kube dir
mkdir -p $HOME/.kube

#copy admin conf to home dir
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

#make sure all files in home are owned after copying files to it
chown -R $(id -u):$(id -g) $HOME

#install flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

#adding configs to the kubelet controller
echo '--allocate-node-cidrs=true\n--cluster-cidr=10.244.0.0/16' >> /etc/kubernetes/manifest/kube-controller-manager.yaml

#restart kubelet 
systemctl restart kubelet

