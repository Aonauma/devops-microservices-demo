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