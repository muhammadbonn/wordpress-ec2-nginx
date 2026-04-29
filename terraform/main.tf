# Standard AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Terraform State Backend Configuration
# This ensures that your infrastructure state is saved in S3, preventing 
# GitHub Actions from creating duplicate resources on every run.
terraform {
  backend "s3" {
    bucket = "muhammad-bonn-terraform-state" # Make sure to create this bucket in AWS manually first
    key    = "prod/wordpress.tfstate"
    region = "us-east-1"
  }
}

# Security Group to allow web traffic and SSH access
resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-sg"
  description = "Allow SSH and HTTP traffic"

  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Web Traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Traffic (Allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SSH Key Pair for EC2 Access
# Note: We changed the 'file()' path to a variable so GitHub Actions can inject it safely
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key 
}

# EC2 Instance Definition
resource "aws_instance" "wordpress_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]

  # Provisioning script to install Docker on startup
  user_data = file("${path.module}/scripts/install_docker.sh")

  tags = {
    Name = "WordPress-Server"
  }
}
