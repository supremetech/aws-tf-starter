resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.0"

  key_name   = local.ssh_key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${module.key_pair.key_pair_name}.pem"
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}
