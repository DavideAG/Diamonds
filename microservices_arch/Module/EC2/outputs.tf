output "instance_ip_addr" {
  description = "EC2 instance public ip"
  value = aws_eip.diamond_eip.public_ip
}