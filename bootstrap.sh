#!/bin/bash

# Enter your email
EMAIL=textxd@berkeley.edu
DOMAIN=textxd.org

# Enter a region & zone
#
# use the us-central1-a zone to take full advantage of all ML GPU types which
# are not available in all regions:
#   https://cloud.google.com/ml-engine/docs/tensorflow/regions#region_considerations
REGION=us-central1
ZONE=${REGION}-a
TYPE=n1-standard-2

gcloud config set compute/zone $ZONE
# Enter a name for your cluster
CLUSTERNAME=shared

# install kubectl
gcloud components install kubectl

gcloud compute addresses create jupyter --region $REGION
IPADDRESS=$(gcloud compute addresses describe jupyter --region us-central1 --format="get(address)")
IPADDRESS=${IPADDRESS:-UNCONFIGURED}

HUBTOKEN=$(openssl rand -hex 32)
PROXYTOKEN=$(openssl rand -hex 32)

# create cluster with 8 nodes for ~26 max simulatneous users
eval "cat <<EOF
$(<config.yaml.template)
EOF
" | tee config.yaml
# NOTE: the eval cat pattern is a bash-ism and may not work in non-bash shells

gcloud beta container clusters create $CLUSTERNAME \
        --cluster-version latest
        --node-labels hub.jupyter.org/node-purpose=core
        --num-nodes=2 \
        --machine-type=$TYPE \
        --zone=$ZONE \
        --enable-autorepair \
        --enable-autoupgrade \
        --enable-autoscaling --min-nodes 1 --max-nodes 5

kubectl create clusterrolebinding cluster-admin-binding \
        --clusterrole=cluster-admin \
        --user=$EMAIL

# get and init helm
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
helm version
kubectl patch deployment tiller-deploy --namespace=kube-system --type=json --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]'

# add jhub helm charts
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update

# retry until tiller active
while [ $? -ne 0 ]; do
    echo "Retrying..."
    sleep 5
    helm repo update
done

# Suggested values: advanced users of Kubernetes and Helm should feel
# free to use different values.
RELEASE=jhub
NAMESPACE=jhub

# install hub
helm upgrade --install $RELEASE jupyterhub/jupyterhub \
     --namespace $NAMESPACE  \
     --version 0.7.0 \
     --values config.yaml

# retry until docker image is fully pulled
while [ $? -ne 0 ]; do
    sleep 5
    echo "Retrying..."
    helm upgrade --install $RELEASE jupyterhub/jupyterhub \
         --namespace $NAMESPACE  \
         --version 0.7.0 \
         --values config.yaml
done

# print pods
kubectl get pod --namespace $NAMESPACE
kubectl get service --namespace $NAMESPACE

# wait until external ip address is established
kubectl --namespace=shared get svc | grep pending
while [ $? -ne 1 ]; do
    echo "IP Pending..."
    sleep 5
    kubectl get service --namespace $NAMESPACE | grep pending
done

kubectl get service --namespace $NAMESPACE
