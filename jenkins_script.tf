locals {
  jenkins_user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install git -y
sudo yum install wget -y
sudo yum install java-11-openjdk -y
sudo wget https://get.jenkins.io/redhat/jenkins-2.346-1.1.noarch.rpm
sudo rpm -ivh jenkins-2.346-1.1.noarch.rpm
sudo yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
cat <<EOT>> /home/ec2-user/.ssh/jenkins_rsa
${tls_private_key.lington_Key.private_key_pem}
EOT
sudo chmod -R 700 .ssh/
sudo chmod -R ec2-user:ec2-user .ssh/
sudo hostnamectl set-hostname Jenkins
EOF
}