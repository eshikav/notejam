#!/bin/bash

if [ $1 == "create" ]
then
helm upgrade --install aws-ebs-csi-driver \
  --version=0.9.8 \
  --namespace kube-system \
  --set serviceAccount.controller.create=false \
  --set serviceAccount.snapshot.create=false \
  --set enableVolumeScheduling=true \
  --set enableVolumeResizing=true \
  --set enableVolumeSnapshot=true \
  --set serviceAccount.snapshot.name=ebs-csi-controller-irsa \
  --set serviceAccount.controller.name=ebs-csi-controller-irsa \
  aws-ebs-csi-driver/aws-ebs-csi-driver
else
helm uninstall aws-ebs-csi-driver --namespace kube-system
fi
