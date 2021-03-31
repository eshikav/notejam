resource "null_resource" "configureALB"{
  depends_on = [aws_eks_node_group.eksClusterNodeGroup]
  provisioner "local-exec" {
    command =  "eksctl create iamserviceaccount --cluster=${aws_eks_cluster.assignmentEksCluster.name} --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=${aws_iam_policy.eksALBRole.arn} --override-existing-serviceaccounts --approve"
  }

  provisioner "local-exec" {
    when = destroy
    command =  "aws cloudformation delete-stack --stack-name eksctl-Assignment-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
  }
}

resource "null_resource" "configureCSI"{
  depends_on = [aws_eks_node_group.eksClusterNodeGroup]
  provisioner "local-exec" {
    command =  "eksctl create iamserviceaccount --cluster=${aws_eks_cluster.assignmentEksCluster.name} --name ebs-csi-controller-irsa --namespace kube-system --attach-policy-arn ${aws_iam_policy.eksCSIRole.arn} --override-existing-serviceaccounts --approve"
  }

  provisioner "local-exec" {
    when = destroy
    command =  "aws cloudformation delete-stack --stack-name eksctl-Assignment-addon-iamserviceaccount-kube-system-ebs-csi-controller-irsa"
  }
}

resource "null_resource" "deployALBController" {
  depends_on = [aws_eks_node_group.eksClusterNodeGroup,null_resource.configureALB]
  provisioner "local-exec" {
    command = "./helper-scripts/deployALBController.sh create"
    }
   provisioner "local-exec" {
    when = destroy
    command = "./helper-scripts/deployALBController.sh destroy"
  }
}

resource "null_resource" "deployCSIController" {
  depends_on = [aws_eks_node_group.eksClusterNodeGroup,null_resource.configureALB]
  provisioner "local-exec" {
    command = "./helper-scripts/csiController.sh create"
    }
   provisioner "local-exec" {
    when = destroy
    command = "./helper-scripts/csiController.sh destroy"
  }
}
