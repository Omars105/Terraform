output "ec2-public-ip" {
  value = module.webserver.instance.public_ip
}