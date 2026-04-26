variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID"
  default     = "ami-0c7217cdde317cfec" 
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default     = "wordpress-key"
}