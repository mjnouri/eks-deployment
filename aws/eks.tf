resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.project_name}_${var.env}_eks_cluster_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}_${var.env}_eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.21"
  vpc_config {
    subnet_ids              = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id, aws_subnet.public_subnet[2].id]
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
  }
  tags = {
    Name = "${var.project_name}_${var.env}_eks_cluster"
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.project_name}_${var.env}_eks_cluster --region us-east-1"
  }
}

# data "tls_certificate" "eks_cluster_tls_cert" {
#   url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "oidc_provider" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks_cluster_tls_cert.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
# }

resource "aws_iam_role" "eks_nodes_role" {
  count              = var.eks_node_group ? 1 : 0
  name               = "${var.project_name}_${var.env}_eks_nodes_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_attachment" {
  count              = var.eks_node_group ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_attachment" {
  count              = var.eks_node_group ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_attachment" {
  count              = var.eks_node_group ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role[0].name
}

resource "aws_eks_node_group" "node_group_1" {
  count              = var.eks_node_group ? 1 : 0
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project_name}_${var.env}_node_group_1"
  node_role_arn   = aws_iam_role.eks_nodes_role[0].arn
  instance_types  = ["t3a.small"]
  subnet_ids      = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id, aws_subnet.private_subnet[2].id]
  scaling_config {
    desired_size = var.eks_node_count_desired
    max_size     = var.eks_node_count_max
    min_size     = var.eks_node_count_min
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_attachment[0],
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_attachment[0],
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_attachment[0]
  ]
}

resource "aws_iam_role" "eks_fargate_role" {
  count              = var.eks_fargate_profile ? 1 : 0
  name = "${var.project_name}_${var.env}_eks_fargate_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy_attachment" {
  count              = var.eks_fargate_profile ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_role[0].name
}

resource "aws_eks_fargate_profile" "eks_fargate_profile" {
  count              = var.eks_fargate_profile ? 1 : 0
  cluster_name           = aws_eks_cluster.eks_cluster.name
  fargate_profile_name   = "${var.project_name}_${var.env}_eks_fargate_profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role[0].arn
  subnet_ids             = aws_subnet.private_subnet[*].id
  selector {
    namespace = "test-ns"
  }
}
