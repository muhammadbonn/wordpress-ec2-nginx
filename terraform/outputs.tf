# --- Infrastructure Outputs ---

# The Public IP address of the newly created EC2 instance
output "public_ip" {
  description = "The public IP address of the WordPress server"
  value       = aws_instance.wordpress_server.public_ip
}

# The Direct URL to access your WordPress site
output "wordpress_url" {
  description = "The URL to access the WordPress website"
  value       = "http://${aws_instance.wordpress_server.public_ip}"
}

# SSH Command helper for quick maintenance access
output "ssh_command" {
  description = "Command to SSH into the server"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.wordpress_server.public_ip}"
}
