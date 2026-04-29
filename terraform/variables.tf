# AWS Region where resources will be deployed
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# EC2 Instance size
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# OS Image ID (Ubuntu 22.04 LTS)
variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID"
  type        = string
  default     = "ami-0c7217cdde317cfec" 
}

# Name of the key pair in AWS Console
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "wordpress-key"
}

# The Public Key string that will be injected via GitHub Actions
variable "public_key" {
  description = "Public SSH key for EC2 access"
  type        = string
}
