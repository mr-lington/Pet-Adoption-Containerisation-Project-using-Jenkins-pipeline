output "Bastion_Server_instance_public_ip" {
  value = aws_instance.Bastion_Server.public_ip
}

output "docker_prod_Server_private_IP" {
  value = aws_instance.docker_prod_Server.private_ip
}

output "docker_stage_Server_private_IP" {
  value = aws_instance.docker_stage_Server.private_ip
}

output "sonarqube_Server_public_IP" {
  value = aws_instance.sonarqude_server.public_ip
}

output "Ansible_Server_public_IP" {
  value = aws_instance.Ansible_Server.public_ip
}

output "Jenkins_Server_public_IP" {
  value = aws_instance.Jenkins_Server.public_ip
}

