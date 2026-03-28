output "server_public_ip" {
  description = "Öffentliche IP der EC2-Instanz"
  value       = aws_instance.app.public_ip
}

output "ssh_command" {
  description = "SSH-Befehl zum Einloggen"
  value       = "ssh ubuntu@${aws_instance.app.public_ip}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "app_url" {
  description = "URL der App"
  value       = "http://${aws_instance.app.public_ip}"
}
