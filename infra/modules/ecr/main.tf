resource "aws_ecr_repository" "api" {
  name         = var.api_repo_name
  force_delete = true
}

resource "aws_ecr_repository" "web" {
  name         = var.web_repo_name
  force_delete = true
}