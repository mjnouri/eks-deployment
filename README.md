# eks-deployment
Deploy a VPC and EKS cluster.

readme work in progress
directions are temporary
switching to module composition, if possible, to simplify apply and destroy

Tooling
1. AWS CLI and authenticate to your AWS account
1. Terraform
1. kubectl

Setup
1. cd ~
1. Clone repo locally with 'git clone ...'
1. cd terraform-aws/
1. Replace providers.tf line 3 with your S3 bucket name to store Terraform remote state
1. Replace variables.tf lines 2, 6, 10 with your name, project name, and environment.
1. Set EKS Cluster node count at variables.tf lines 14, 18, and 22
1. Set EKS Fargate profile and Node Group to true or false at variables.tf lines 26 and 30.
1. cd ../terraform-k8s/
1. Replace providers.tf line 3 with your S3 bucket name to store Terraform remote state

Apply infrastructure
1. cd ~/eks-deployment/terraform-aws/
1. terraform init
1. terraform plan
1. terraform apply -auto-approve
1. copy eks_cluster_name output
1. cd ../terraform-k8s
1. set cluster name from step 5 at providers.tf lines 20 and 24
1. terraform init
1. terraform plan
1. terraform apply -auto-approve

Validate infrastructure
1. kubectl cluster-info
...

Destroy infrastructure
1. Remove all EKS resources created outside of Terraform (add why)
1. cd ~/eks-deployment/terraform-k8s
1. terraform destroy -auto-approve
1. cd ../terraform-aws
1. terraform destroy -auto-approve
