locals {
  ansible_ubuntu_user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update -y
sudo apt install ansible -y
sudo hostnamectl set-hostname ansible
sudo apt install docker.io -y
sudo mkdir /opt/docker
sudo chown -R ubuntu:ubuntu /opt/docker
sudo chmod -R 700 /opt/docker
sudo chmod -R 700 /home/ubuntu/.ssh
sudo chmod 700 /home/ubuntu/.ssh/authorized_keys
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh
sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
echo "${tls_private_key.lington_Key.private_key_pem}" >> /home/ubuntu/.ssh/anskey_rsa
sudo chmod 400 anskey_rsa
cat <<EOT>> /etc/ansible/hosts
localhost ansible_connection=local
[docker_stage]
${data.aws_instance.docker_stage_Server.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/anskey_rsa
[docker_prod]
${data.aws_instance.docker_prod_Server.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/anskey_rsa
EOT
EOF
}