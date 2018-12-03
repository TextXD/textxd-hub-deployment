#!/bin/bash

# delete namespace
kubectl delete namespace jhub

# destroy cluster
gcloud container clusters delete shared --zone=us-central1-a

# check gone
gcloud container clusters list
