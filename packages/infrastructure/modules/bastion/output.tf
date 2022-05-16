output "endpoint" {
  value = var.up ? aws_instance.default[0].public_dns : ""
}

output "sg_id" {
  value = aws_security_group.bastion-sg.id
}
