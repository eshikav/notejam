resource "aws_iam_role" "eksClusterRole" {
  name = "eksAmazonEKSClusterRole"
  assume_role_policy = jsonencode({
     Version = "2012-10-17"
     "Statement" = [
     {
        "Effect" = "Allow",
        "Principal" = {
        "Service" = "eks.amazonaws.com"
      },
     "Action" = "sts:AssumeRole"
     },
  ]
  })

  tags = {
    tag-key = "eksAmazonEKSClusterRole"
  }
}

resource "aws_iam_role" "eksAmazonEKSNodeRole" {
  name = "eksAmazonEKSNodeRole"
  assume_role_policy = jsonencode({
     "Version" = "2012-10-17",
     "Statement" = [
     {
       "Effect" = "Allow",
       "Principal" = {
        "Service" = "ec2.amazonaws.com"
       },
       "Action" = "sts:AssumeRole"
     }
     ]
  })

  tags = {
    tag-key = "eksAmazonEKSNodeRole"
  }
}

locals {
    nodePolicies = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}

resource "aws_iam_role_policy_attachment" "eksClusterRoleAttachment" {
  role       = aws_iam_role.eksClusterRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eksClusterNodeAttachment" {
  count      =  length(local.nodePolicies)
  role       = aws_iam_role.eksAmazonEKSNodeRole.name
  policy_arn = element(local.nodePolicies, count.index)
}

resource "aws_iam_role" "eksAmazonEKSCNIRole" {
  name = "eksAmazonEKSCNIPolicy"
  assume_role_policy  = jsonencode({
     "Version" = "2012-10-17",
     "Statement" = [
       {
        "Effect" = "Allow",
        "Principal" = {
          "Federated" = aws_iam_openid_connect_provider.eksOpenIdProvider.arn
       },
     "Action" = "sts:AssumeRoleWithWebIdentity",
     "Condition" = {
        "StringEquals" = {
           "${aws_iam_openid_connect_provider.eksOpenIdProvider.url}:sub" = "system:serviceaccount:kube-system:aws-node"
        }
      }
    }
  ]
  })

}

resource "aws_iam_policy" "eksALBRole" {
  name = "eksAmazonEKSCNIPolicy"
  policy  = file("./files/albIAMPolicy.json")
}

resource "aws_iam_policy" "eksCSIRole" {
  name = "eksAmazonEKSCNIPolicy"
  policy  = file("./files/ebs-csi-policy.json")
}
