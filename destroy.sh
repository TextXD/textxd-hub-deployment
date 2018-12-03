# delete namespace
kubectl delete namespace shared

# destroy cluster
gcloud container clusters delete shared --zone=us-central1-a

# check gone
gcloud container clusters list
