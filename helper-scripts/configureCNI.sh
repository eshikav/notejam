#!/bin/bash

if [ $1 == "create" ]
then
rm -rf ~/.kube/*
aws eks update-kubeconfig --name $EKS_CLUSTER
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.7/aws-k8s-cni.yaml
else
kubectl delete -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.7/aws-k8s-cni.yaml
fi
