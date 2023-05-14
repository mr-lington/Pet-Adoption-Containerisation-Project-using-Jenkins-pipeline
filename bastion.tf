locals {
  bastion_user_data = <<-EOF
#!/bin/bash
echo "${tls_private_key.lington_Key.private_key_pem}" > /home/ec2-user/lington_Key
chmod 400 lington_Key
sudo hostnamectl set-hostname Bastion
EOF
}