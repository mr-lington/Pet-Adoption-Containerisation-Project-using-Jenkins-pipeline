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

touch /opt/docker/Dockerfile
cat <<EOT>> /opt/docker/Dockerfile
FROM openjdk
COPY spring-petclinic-2.4.2.war app/
WORKDIR app
ENTRYPOINT ["java", "-jar", "spring-petclinic-2.4.2.war", "--server.port=8085"] 
EOT

touch /opt/docker/docker_image.yaml
cat <<EOT>> /opt/docker/docker_image.yaml
---
 - name: ansible playbook for docker image
   hosts: localhost
   become: true

   tasks:
   - name: login  to our docker hub account
     command: docker login --username=lington --password=@Darboy123
     

   - name: create/build docker image from our Dockerfile   
     command: docker build -t lington-docker-image .
     args:
      chdir: /opt/docker

   - name: create docker tag before we push our image to docker hub
     command: docker tag super-docker-image lington/super-docker-image

   - name: push to docker hub
     command: docker push lington/super-docker-image

   - name: remove docker image after pushing
     command: docker rmi lington/super-docker-image super-docker-image
     ignore_errors: yes
EOT

touch /opt/docker/docker_stage.yaml
cat <<EOT>> /opt/docker/docker_stage.yaml
---
 - name: this is a ansible playbook for docker stage for testing
   hosts: docker_stage
   become: true

   tasks:
   - name: login  to our docker hub account
     command: docker login --username=lington --password=@Darboy123
    
   
   - name: lets assume that our container is already running so we need to stop it
     command: docker stop test-docker-container
     ignore_errors: yes

   - name: remove docker stopped docker container
     command: docker rm test-docker-container
     ignore_errors: yes

   - name: remove the docker image after pushing
     command: docker rmi lington/super-docker-image lington-docker-image
     ignore_errors: yes

   - name: pull docker image from docker hub account
     command: docker pull lington/super-docker-image

   - name: Create docker container for stage from the image we pulled from dockerhub
     command: docker run -itd  --name test-docker-container -p 8080:8085 lington/super-docker-image
EOT

touch /opt/docker/docker_prod.yaml
cat <<EOT>> /opt/docker/docker_prod.yaml
---
 - name: this is a ansible playbook for docker prod for production environment
   hosts: docker_prod
   become: true

   tasks:
   - name: login  to our docker hub account
     command: docker login --username=lington --password=@Darboy123
     
   
   - name: lets assume that our container is already running so we need to stop it
     command: docker stop test-docker-container
     ignore_errors: yes

   - name: remove docker stopped docker container
     command: docker rm test-docker-container
     ignore_errors: yes

   - name: remove the docker image after pushing
     command: docker rmi lington/super-docker-image lington-docker-image
     ignore_errors: yes

   - name: pull docker image from docker hub account
     command: docker pull lington/super-docker-image

   - name: Create docker container for stage from the image we pulled from dockerhub
     command: docker run -itd  --name test-docker-container -p 8080:8085 lington/super-docker-image
EOT
EOF
}