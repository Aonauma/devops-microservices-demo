variable "aws_region" {
  default = "ap-southeast-7"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "kubernetes_version" {
  default = "1.29"
}

variable "instance_types" {
  default = ["t3.medium"]
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 2
}

variable "desired_size" {
  default = 1
}

variable "enable_lb_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = false
}
variable "enable_eks_access" {
  description = "Enable EKS access entry creation"
  type        = bool
  default     = false
}

variable "eks_admin_principal_arn" {
  description = "IAM principal ARN to grant EKS cluster admin"
  type        = string
  default     = "arn:aws:iam::113892880964:user/admin"
}