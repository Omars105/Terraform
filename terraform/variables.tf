variable "vpc-cidr-block" {
    default = "10.0.0.0/16"
}
variable "subnet-cidr-block" {
    default = "10.0.1.0/24"
}
variable "availability-zone" {
    default = "us-east-1a"
}
variable "env-prefix" {
    default = "dev"
}
variable "my-ip" {
    default = "197.46.229.191/32"
}
variable "instance_type" {
    default = "t3.micro"
}

variable "region" {
  default = "us-east-1"
}