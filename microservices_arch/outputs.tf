output "api_url_complete" {
    value = module.api_gateway.complete_unvoke_url
}

output "EC2_instance_ip_addr" {
    value = module.EC2.instance_ip_addr
}