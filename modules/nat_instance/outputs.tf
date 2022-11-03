output "eni_id" {
  description = "ID of the ENI for the NAT instance"
  value       = aws_network_interface.this.id
}

output "eni_private_ip" {
  description = "Private IP of the ENI for the NAT Instance"
  value       = tolist(aws_network_interface.this.private_ips)[0]
}

output "iam_role_name" {
  description = "Name of the IAM role for the NAT instance"
  value       = aws_iam_role.this.name
}