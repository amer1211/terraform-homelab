output "server_ip" {
  description = "Öffentliche IP des Servers"
  value       = hcloud_server.web.ipv4_address
}

output "server_name" {
  description = "Name des Servers"
  value       = hcloud_server.web.name
}

output "ssh_command" {
  description = "SSH-Befehl zum Einloggen"
  value       = "ssh root@${hcloud_server.web.ipv4_address}"
}
