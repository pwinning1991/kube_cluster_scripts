## Very Basic scripts for setting up Kube Master and Workers with kubeadm
## This is not a production ready configuration/ only is setup for a single master

### Run the kubemaster.sh on the kube master and then run kubeworker.sh on worker nodes
### You will need to run using sudo
### These are configured and tested on centos7
#### Normally this would be done with config management, may rewrite in ansible at some time


#### Steps for master node
```bash
git clone https://github.com/pwinning1991/kube_cluster_scripts.git
cd kube_cluster_scripts
chmod 750 kubemaster.sh
sudo ./kubemaster.sh
```
#### When the script finished you will need the join token and sha256 of the cert to run the worker nodes script
