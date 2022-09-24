variable "owner" {
  default = "OWNER"
}

variable "project_name" {
  default = "PROJECT_NAME"
}

variable "env" {
  default = "ENV"
}

variable "eks_node_count_desired" {
  default = 2
}

variable "eks_node_count_max" {
  default = 2
}

variable "eks_node_count_min" {
  default = 2
}

variable "eks_fargate_profile" {
  default = false
}

variable "eks_node_group" {
  default = true
}

variable "public_subnet_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "az" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
