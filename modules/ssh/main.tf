resource "tls_private_key" "ssh" {
  count     = var.ssh_public_key != "" ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Write private key to disk, if no public key provided missing
resource "local_file" "private_key" {
  count    = var.ssh_public_key != "" ? 0 : 1
  content  = tls_private_key.ssh[0].private_key_pem
  filename = "./private_ssh_key"
}
