#!/bin/sh
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

 #-init-gateways -gateway-localnet \
