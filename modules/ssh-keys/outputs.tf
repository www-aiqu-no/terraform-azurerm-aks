output "public_ssh_key" {
  description = ""
  value       = var.enabled ? tls_private_key.ssh.public_key_openssh : null
}
