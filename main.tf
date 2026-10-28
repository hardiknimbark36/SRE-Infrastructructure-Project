terraform {
   backend "s3" {
    bucket         = "sre-tf-state-aeda26ff"
    key            = "sre-project/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile   = true
    encrypt        = true
  }
   
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}



provider "aws" {
  region = var.aws_region
}

# Generates a random suffix to ensure your S3 bucket name is globally unique
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket to hold the Terraform .tfstate file
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "sre-tf-state-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# Enable versioning so you can roll back state if something breaks
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB Table for State Locking (prevents concurrent applies)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "sre-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"  
  }
}


# COMPUTE & NETWORKING

# 1. Dynamically fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 2. Security Group (Firewall) to allow SSH and HTTP traffic
resource "aws_security_group" "web_sg" {
  name        = "sre-web-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id 

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
