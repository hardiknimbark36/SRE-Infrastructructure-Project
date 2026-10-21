# Highly Available AWS Infrastructure with CI/CD Automation

## ☁️ Overview
This project demonstrates a production-ready, highly available AWS architecture built entirely with Infrastructure as Code (IaC). It features an automated CI/CD deployment pipeline, secure remote state management, and active system observability, reflecting modern Site Reliability Engineering (SRE) best practices.

## 🛠️ Key Technologies
- **Cloud Provider:** AWS (ap-south-1)
- **Infrastructure as Code:** Terraform
- **CI/CD:** GitHub Actions
- **Core Services:** VPC, Auto Scaling Group (ASG), Application Load Balancer (ALB), S3, DynamoDB, CloudWatch

## 🏗️ Architecture Highlights
- **High Availability:** Traffic is distributed across multiple Availability Zones using an Application Load Balancer.
- **Auto-Scaling:** EC2 instances automatically scale to ensure consistent performance.
- **Automated CI/CD:** A GitHub Actions pipeline validates, formats, and deploys infrastructure changes automatically.
- **Secure State Management:** Terraform state is securely stored in an S3 bucket with state locking enabled to prevent concurrent modification corruption.
- **Active Observability:** CloudWatch alarms monitor ASG CPU utilization to proactively alert on performance bottlenecks.

## 🚀 How to Deploy

### Prerequisites
- AWS Account with IAM user credentials
- Terraform installed locally
- GitHub repository with AWS credentials stored as Actions Secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)

### Deployment Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/hardiknimbark36/SRE-Infrastructructure-Project.git
   cd SRE-Infrastructructure-Project
   
   
2. Initialize Terraform:
```bash
terraform init
```

3. Review the deployment plan:
```bash
terraform plan
```

4. Deploy the infrastructure:
```bash
terraform apply
```

5. Tear down (when finished):
```bash
terraform destroy
```
