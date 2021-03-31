#!/bin/bash

if [ $1 == "create" ]
then
kubectl apply -f ./files/cert-manager.yaml
kubectl apply -f ./files/albController.yml
else
kubectl delete -f ./files/albController.yml
kubectl delete -f ./files/cert-manager.yaml
exit 0
fi
