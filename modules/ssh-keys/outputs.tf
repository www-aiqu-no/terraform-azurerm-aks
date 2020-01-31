output "public_ssh_key" {
  # Only output if ssh public key is generated
  value = var.enabled ? tls_private_key.ssh.public_key_openssh : ""
}
