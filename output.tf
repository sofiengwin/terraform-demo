output "PrivateIP" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "Web-Server-URL" {
  description = "Web-Server-URL"
  value       = join("", ["http://", aws_instance.app_server.public_ip])
}

output "Time-Date" {
  description = "Date/Time of Execution"
  value       = timestamp()
}