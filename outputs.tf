output "eksClusterInfo" {
   value = aws_iam_openid_connect_provider.eksOpenIdProvider.arn
}
output "thumbprint"{
   value = data.external.thumbprint.result.thumbprint
}

output "oidcProviderARN" {
value = aws_iam_openid_connect_provider.eksOpenIdProvider.arn
}

