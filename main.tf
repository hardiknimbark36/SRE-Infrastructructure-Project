terraform {
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
  region = "ap-south-1"
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

output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "The name of the S3 bucket for remote state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table for state locking"
}


# --- COMPUTE & NETWORKING ---

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

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. The actual Linux Server (Free Tier Eligible)
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro" 
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>SRE Portfolio Project - Deployed via Terraform</h1><p>Server IP: $(hostname -I)</p>" > /var/www/html/index.html
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "SRE-App-Server-1"
  }
}

# 4. Output the Public IP so we can access it
output "instance_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP address of the web server"
}
