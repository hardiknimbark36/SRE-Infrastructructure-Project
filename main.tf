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