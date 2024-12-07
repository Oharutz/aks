#!/bin/bash
set -e
set -x

echo "Authenticating with Azure using Managed Identity..."
az login --identity

echo "Fetching AKS credentials for the cluster..."
az aks get-credentials --admin --name $2 --resource-group $1
echo "Adding Helm repository..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "Deploying the NGINX ingress controller..."
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-basic --create-namespace \
  --set controller.service.annotations."service.beta.kubernetes.io/azure-load-balancer-internal"="true"

echo "Validating the deployment..."
kubectl get pods -n ingress-basic
kubectl get svc -n ingress-basic

echo "NGINX ingress controller deployment completed successfully."
