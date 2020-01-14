# output

output "id" {
  value = data.aws_eks_cluster.cluster.id
}

output "name" {
  value = data.aws_eks_cluster.cluster.name
}

output "version" {
  value = data.aws_eks_cluster.cluster.version
}

output "endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "certificate_authority" {
  value = data.aws_eks_cluster.cluster.certificate_authority.0.data
}

output "token" {
  value = data.aws_eks_cluster_auth.cluster.token
}

output "security_group_id" {
  value = aws_security_group.cluster.id
}

output "role_arn" {
  value = aws_iam_role.cluster.arn
}
