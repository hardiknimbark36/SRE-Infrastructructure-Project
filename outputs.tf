output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.id
  description = "The name of the S3 bucket for remote state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table for state locking"
}

output "alb_dns_name" {
  value       = aws_lb.app_alb.dns_name
  description = "The domain name of the load balancer"
}