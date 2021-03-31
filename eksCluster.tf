#Resource to deploy the EKS cluster for the notejam WorkLoads
resource aws_eks_cluster "assignmentEksCluster" {
   name = var.eksClusterInfo.name
   role_arn = aws_iam_role.eksClusterRole.arn
   vpc_config {
    subnet_ids = [for key,value in aws_subnet.eksPublicSubnets: value.id]
    security_group_ids = [aws_security_group.eksSecGroup.id]
   }
   kubernetes_network_config {
    service_ipv4_cidr = var.eksClusterInfo.kubernetesNetworkConfig
   }
}
