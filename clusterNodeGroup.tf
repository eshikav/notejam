resource "time_sleep" "wait" {
  destroy_duration = "60s"
  depends_on = [aws_eks_cluster.assignmentEksCluster] 
}

resource "null_resource" "configureCNI" {
  depends_on = [time_sleep.wait,aws_eks_cluster.assignmentEksCluster]
  provisioner "local-exec" {
    command = "./helper-scripts/configureCNI.sh create"
    environment = {
      EKS_CLUSTER = aws_eks_cluster.assignmentEksCluster.name
    }
  }
   provisioner "local-exec" {
    when = destroy
    command = "./helper-scripts/configureCNI.sh destroy"
  }
}



resource "aws_key_pair" "eksNodeGroupSSHKey" {
  key_name   = "eksNodeGroupSSHKey"
  public_key = file(var.eksCommonConfig.sshPublicKeyFile)
}

resource "aws_eks_node_group" "eksClusterNodeGroup" {
  cluster_name    = aws_eks_cluster.assignmentEksCluster.name
  node_group_name = var.eksClusterNodeGroupInfo.name
  node_role_arn   = aws_iam_role.eksAmazonEKSNodeRole.arn
  subnet_ids      = [for key,value in aws_subnet.eksPrivateSubnets: value.id]
  ami_type        = var.eksClusterNodeGroupInfo.ami_type
  capacity_type   = var.eksClusterNodeGroupInfo.capacity_type
  instance_types  = [var.eksClusterNodeGroupInfo.instance_types]
  disk_size       = var.eksClusterNodeGroupInfo.disk_size
  remote_access {
     ec2_ssh_key     = aws_key_pair.eksNodeGroupSSHKey.id
  }
  scaling_config {
    desired_size = var.eksClusterNodeGroupScalingInfo.desired_size
    max_size     = var.eksClusterNodeGroupScalingInfo.max_size
    min_size     = var.eksClusterNodeGroupScalingInfo.min_size
  }

  depends_on = [aws_iam_role_policy_attachment.eksClusterNodeAttachment,aws_key_pair.eksNodeGroupSSHKey, aws_eks_cluster.assignmentEksCluster, null_resource.configureCNI]
  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.assignmentEksCluster.name}" = "shared"
  }
}
