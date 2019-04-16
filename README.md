# kubernetes-ovn-deploy
## 步骤：
1.
安装kubernetes-ovn   [kubernetes-ovn](https://github.com/openvswitch/ovn-kubernetes)

2.
安装openvswitch [openvswich](http://docs.openvswitch.org/en/latest/intro/install)

$./boot.sh &&./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc CFLAGS="-g -O2 -msse4.2"



3.
centos安装 kubernetes

```
all node run:

$ setenforce  0
$ systemctl stop firewalld
$ systemctl disable firewalld
$ swapoff -a

$ cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
$ sysctl --system

$ cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

$ yum install -y docker
$ systemctl enable docker && systemctl start docker
$ systemctl enable docker.service
$ yum install -y kubelet-1.11.0 kubeadm-1.11.0 kubectl-1.11.0 kubernetes-cni
$ systemctl enable kubelet && systemctl start kubelet


```

* * *
```
Master node run:

#!/bin/bash
images=(kube-proxy-amd64:v1.11.0 kube-scheduler-amd64:v1.11.0 kube-controller-manager-amd64:v1.11.0 kube-apiserver-amd64:v1.11.0
etcd-amd64:3.2.18 coredns:1.1.3 pause-amd64:3.1 kubernetes-dashboard-amd64:v1.8.3 )
for imageName in ${images[@]} ; do
  docker pull registry.cn-hangzhou.aliyuncs.com/k8sth/$imageName
  docker tag registry.cn-hangzhou.aliyuncs.com/k8sth/$imageName k8s.gcr.io/$imageName
  #docker rmi registry.cn-hangzhou.aliyuncs.com/k8sth/$imageName
done
docker tag da86e6ba6ca1 k8s.gcr.io/pause:3.1

kubeadm init --kubernetes-version=v1.11.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=10.121.222.17 -v6

---------------------------------------------------

Your Kubernetes master has initialized successfully!
 
To start using your cluster, you need to run the following as a regular user:
 
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
 
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/
 
You can now join any number of machines by running the following on each node
as root:
 
  kubeadm join 10.121.222.17:6443 --token wkj0bo.pzibll6rd9gyi5z8 --discovery-token-ca-cert-hash sha256:51985223a369a1f8c226f3ccdcf97f4ad5ff201a7c8c708e1636eea0739c0f05

```

* * *
```
slave node run:

kubeadm join 10.121.222.17:6443 --token wkj0bo.pzibll6rd9gyi5z8 --discovery-token-ca-cert-hash sha256:51985223a369a1f8c226f3ccdcf97f4ad5ff201a7c8c708e1636eea0739c0f05
```


* * *
master启动服务：
```
$/etc/init.d/openvswitch start

$systemctl start ovn-northd.service
$systemctl start ovn-controller.service

$#!/bin/sh
CLUSTER_IP_SUBNET="10.1.0.0/12"
SERVICE_IP_SUBNET="10.96.0.0/12"
NODE_NAME="ovn-node1.novalocal"
CENTRAL_IP="192.168.20.14"
#TOKEN=va5x9r.yewa8y1kj4txvx1w
TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im92bmt1YmUtdG9rZW4tYjdjcGMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoib3Zua3ViZSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjQwY2FjNTgzLTVhOWQtMTFlOS1iOGViLWZhMTYzZThiYzRkZSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0Om92bmt1YmUifQ.SCcr9C4VhzE1oVj6itUFBXWimBGNB21IkVT8GDvdMbVaV4KvERD3ugT9JkeVuDMrGj5bC7xlcjJROjpbq8zWf-EMCdWe5SR8N0as_KnxcVNkmS5O3qtjsu7P-CC-_l3nEEiwO_dZFmg5e6TElhSjBefZBMEBs4Vl-60XFZlyTQT_hMNuIRckhjqnzSNeDn0oh47BMMhbraxQDQTavhGTh-NHBwINgXQmiB-7rV2aWHlVm32ot9lhVYUOKgnksZJaExA-khO8Nj7pttpfKQXh_bRbrUEIJJB1gVCeCf5eXSSWSaE-At4b77_we4b4-QrINYS1-5FSRV5HxeTNgDSn5g

nohup sudo ovnkube -k8s-kubeconfig /etc/kubernetes/admin.conf  -net-controller \
 -loglevel=5 \
 -k8s-apiserver="http://$CENTRAL_IP:8080" \
 -logfile="/var/log/ovn-kubernetes/ovnkube.log" \
 -init-master=$NODE_NAME -init-node=$NODE_NAME \
 -cluster-subnet="$CLUSTER_IP_SUBNET" \
 -service-cluster-ip-range=$SERVICE_IP_SUBNET \
 -nodeport \
 -k8s-token="$TOKEN" \
 -nb-address="tcp://$CENTRAL_IP:6641" \
 -sb-address="tcp://$CENTRAL_IP:6642" 2>&1 &
echo $?
```

slave启动服务：
```
$/etc/init.d/openvswitch start
$systemctl start ovn-controller.service

$#!/bin/sh
CLUSTER_IP_SUBNET="10.1.0.0/12"
SERVICE_IP_SUBNET="10.96.0.0/12"
NODE_NAME="ovn-node2.novalocal"
CENTRAL_IP="192.168.20.14"
#TOKEN=va5x9r.yewa8y1kj4txvx1w
TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6Im92bmt1YmUtdG9rZW4tYjdjcGMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoib3Zua3ViZSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjQwY2FjNTgzLTVhOWQtMTFlOS1iOGViLWZhMTYzZThiYzRkZSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0Om92bmt1YmUifQ.SCcr9C4VhzE1oVj6itUFBXWimBGNB21IkVT8GDvdMbVaV4KvERD3ugT9JkeVuDMrGj5bC7xlcjJROjpbq8zWf-EMCdWe5SR8N0as_KnxcVNkmS5O3qtjsu7P-CC-_l3nEEiwO_dZFmg5e6TElhSjBefZBMEBs4Vl-60XFZlyTQT_hMNuIRckhjqnzSNeDn0oh47BMMhbraxQDQTavhGTh-NHBwINgXQmiB-7rV2aWHlVm32ot9lhVYUOKgnksZJaExA-khO8Nj7pttpfKQXh_bRbrUEIJJB1gVCeCf5eXSSWSaE-At4b77_we4b4-QrINYS1-5FSRV5HxeTNgDSn5g

nohup sudo ovnkube -k8s-kubeconfig /root/.kube/config \
 -loglevel=5 \
 -k8s-apiserver="http://$CENTRAL_IP:8080" \
 -logfile="/var/log/ovn-kubernetes/ovnkube.log" \
 -init-node=$NODE_NAME \
 -cluster-subnet="$CLUSTER_IP_SUBNET" \
 -service-cluster-ip-range=$SERVICE_IP_SUBNET \
 -nodeport \
 -k8s-token="$TOKEN" \
 -nb-address="tcp://$CENTRAL_IP:6641" \
 -sb-address="tcp://$CENTRAL_IP:6642" 2>&1 &

echo $?

#-init-gateways -gateway-localnet \
```
