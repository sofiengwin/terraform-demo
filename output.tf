output "PrivateIP" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.app_server.private_ip
}