output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "app_url" {
  description = "Direct health check URL"
  value       = "http://${aws_instance.app_server.public_ip}:8000/health"
}