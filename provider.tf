terraform {
  backend "s3" {
    bucket = "BUCKET_NAME"
    key    = "tf-state/eks-deployment/terraform.tfstate"
    region = "us-east-1"
  }
  # required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = "= 4.14.0"
  #   }
  #   kubernetes = {
  #     source  = "hashicorp/kubernetes"
  #     version = "= 2.11.0"
  #   }
  #   tls = {
  #     source  = "hashicorp/tls"
  #     version = "= 3.4.0"
  #   }
  # }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      owner        = var.owner
      project_name = var.project_name
      env          = var.env
    }
  }
}

data "aws_eks_cluster" "aws_eks_cluster" {
  name = module.aws.output.eks_cluster_name
}

data "aws_eks_cluster_auth" "aws_eks_cluster_auth" {
  name = "CLUSTER_NAME"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.aws_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.aws_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.aws_eks_cluster_auth.token
}
