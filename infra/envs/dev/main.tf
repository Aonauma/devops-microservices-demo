module "vpc" {
  source = "../../modules/vpc"

  name            = "devops-microservice-demo-vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "devops-microservice-demo"
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  instance_types     = var.instance_types
  min_size           = var.min_size
  max_size           = var.max_size
  desired_size       = var.desired_size
}

module "ecr" {
  source = "../../modules/ecr"

  api_repo_name = "devops-microservice-demo-api"
  web_repo_name = "devops-microservice-demo-web"
}