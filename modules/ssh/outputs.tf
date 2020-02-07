# Return either new key, or the provided key
output "ssh_public_key" {
  description = "The public ssh-key for connecting to nodes in the cluster"
  sensitive   = false
  # Always returns a string
  # Fix: fails if 0
  value = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh
}
