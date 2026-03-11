resource "aws_eks_access_entry" "admin_user" {
  count = var.enable_eks_access ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = var.eks_admin_principal_arn

  type = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin_user_cluster_admin" {
  count = var.enable_eks_access ? 1 : 0

  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.admin_user[0].principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.admin_user
  ]
}