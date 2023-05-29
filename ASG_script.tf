locals {
  user_data_ASG = <<-EOF
  #!/bin/bash
  sudo docker restart test-docker-container
  EOF
}