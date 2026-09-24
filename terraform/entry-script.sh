#!/bin/bash
  sudo yum update -y && sudo yum install -y docker
  sudo systemctl start docker && sudo systemctl enable docker
  sudo usermod -aG docker ec2-user

#download docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
