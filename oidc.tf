data "aws_region" "current" {}

data "external" "thumbprint" {
  program = ["./helper-scripts/oidc-thumbprint.sh", data.aws_region.current.name]
}

resource "aws_iam_openid_connect_provider" "eksOpenIdProvider" {
  url = aws_eks_cluster.assignmentEksCluster.identity[0]["oidc"][0]["issuer"]
  client_id_list =["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  depends_on = [data.external.thumbprint]
}
