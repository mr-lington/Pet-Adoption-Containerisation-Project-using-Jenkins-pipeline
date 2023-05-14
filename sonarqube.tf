locals {
  sonarqube_user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo docker run -it -d --name sonarqube -p 9000:9000 sonarqube
sudo hostnamectl set-hostname sonarqube
  EOF
} #sonarqube has be installed with a docker container because its more easier than writing a script for it