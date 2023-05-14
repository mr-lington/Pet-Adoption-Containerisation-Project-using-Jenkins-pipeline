locals {
  user_data_docker_prod = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install docker.io -y
  sudo hostnamectl set-hostname Docker-prod
  sudo bash -c 'echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
  EOF
}


# sudo bash -c 'echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config  ====== dont ask for approval when trying to ssh into the docker