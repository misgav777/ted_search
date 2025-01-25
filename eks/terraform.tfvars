#project variables 
env          = "Dev"
project_name = "Ted-search"

# EKS variables
eks_name    = "ted-search-cluster"
eks_version = "1.32"

# VPC variables
region               = "ap-south-1"
vpc_cider_block      = "10.0.0.0/16"
azs                  = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# EC2 instance variables
instance_type = "t3a.small"
key_name      = "develeap"
