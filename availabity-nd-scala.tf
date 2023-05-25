# Inorder to create a ALB for docker stage and docker prod, first we must create a separate security groups and the listener will either be http port 80 or https port 443

# Creating Security group docker stage App load Balancer
resource "aws_security_group" "docker_stage_ALB_SG" {
  name        = "docker_stage_ALB_SG"
  description = "docker stage traffic"
  vpc_id      = aws_vpc.lington-vpc.id

  ingress {
    description = "application traffic"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }

  ingress {
    description = "listener traffic"
    from_port   = var.unsecured_listener_port
    to_port     = var.unsecured_listener_port
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }

  egress {
    from_port   = var.egress_from_and_to
    to_port     = var.egress_from_and_to
    protocol    = var.egress_protocol
    cidr_blocks = var.allow_all_IP
  }

  tags = {
    Name = "docker_stage_ALB_SG"
  }
}

# Creating Security group docker production App load Balancer
resource "aws_security_group" "docker_prod_ALB_SG" {
  name        = "docker_prod_ALB_SG"
  description = "docker production traffic"
  vpc_id      = aws_vpc.lington-vpc.id

  ingress {
    description = "application traffic"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }

  ingress {
    description = "listener traffic"
    from_port   = var.unsecured_listener_port
    to_port     = var.unsecured_listener_port
    protocol    = "tcp"
    cidr_blocks = var.allow_all_IP
  }

  egress {
    from_port   = var.egress_from_and_to
    to_port     = var.egress_from_and_to
    protocol    = var.egress_protocol
    cidr_blocks = var.allow_all_IP
  }

  tags = {
    Name = "docker_prod_ALB_SG"
  }
}

# Create  Target Group for docker stage
resource "aws_lb_target_group" "lington_docker_stage_ALB_TG" {
  name     = "lington-docker-stage-ALB-TG"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.lington-vpc.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
    path                = "/"
  }

}

# Create Stage Target Group Attachment
resource "aws_lb_target_group_attachment" "lington_docker_stage_alb_attach" {
  target_group_arn = aws_lb_target_group.lington_docker_stage_ALB_TG.arn
  target_id        = aws_instance.docker_stage_Server.id
  port             = var.app_port
}

#Create Stage Load Balancer for stage
resource "aws_lb" "lington_docker_stage_ALB" {
  name               = "lington-docker-stage-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.docker_stage_ALB_SG.id]
  subnets            = [aws_subnet.lington-pub1.id, aws_subnet.lington-pub2.id]

  enable_deletion_protection = false


  tags = {
    Environment = "Development"
  }
}

#Create Stage Load Balancer Listener
resource "aws_lb_listener" "lington_docker_stage_ALB_listener" {
  load_balancer_arn = aws_lb.lington_docker_stage_ALB.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lington_docker_stage_ALB_TG.arn
  }
}

# Create  Target Group for docker production
resource "aws_lb_target_group" "lington_docker_prod_ALB_TG" {
  name     = "lington-docker-prod-ALB-TG"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.lington-vpc.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
    path                = "/"
  }

}

# Create production Target Group Attachment
resource "aws_lb_target_group_attachment" "lington_docker_prod_alb_attach" {
  target_group_arn = aws_lb_target_group.lington_docker_prod_ALB_TG.arn
  target_id        = aws_instance.docker_prod_Server.id
  port             = var.app_port
}

#Create Load Balancer for production
resource "aws_lb" "lington_docker_prod_ALB" {
  name               = "lington-docker-prod-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.docker_prod_ALB_SG.id]
  subnets            = [aws_subnet.lington-pub1.id, aws_subnet.lington-pub2.id]

  enable_deletion_protection = false


  tags = {
    Environment = "Development"
  }
}

#Create production Load Balancer Listener
resource "aws_lb_listener" "lington_docker_prod_ALB_listener" {
  load_balancer_arn = aws_lb.lington_docker_prod_ALB.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lington_docker_prod_ALB_TG.arn
  }
}

# creating the auto scaling group, 
# first create AMI image from the docker production instance
resource "aws_ami_from_instance" "lington_docker_prod_AMI_image" {
  name                    = "lington-docker-prod-AMI-image"
  source_instance_id      = aws_instance.docker_prod_Server.id
  snapshot_without_reboot = true

  depends_on = [
    aws_instance.docker_prod_Server
  ]
  tags = {
    Name = "lington_docker_prod_AMI_image"
  }
}

# # # # Create launch configuration
# # # resource "aws_launch_configuration" "lington_docker_prod_lconfig" {
# # #   name_prefix                          = "lington-lt"
# # #   image_id                             = aws_ami_from_instance.lington_docker_prod_AMI_image.id
# # #   instance_type                        = "t2.micro"
# # #   key_name                             = aws_key_pair.lington_Key_pub.key_name
# # #   associate_public_ip_address          = false
# # #   security_groups                      = [aws_security_group.docker_prod_lington_BackEndSG.id]
# # #   user_data                            = local.user_data_ASG
# # #   #user_data                            = filebase64("${path.module}/asgolu.sh")
  
# # #   /* monitoring {
# # #     enabled = true
# # #   } */
 
# # #   lifecycle {
# # #     create_before_destroy = false
# # #   }
# # # }

# # # # Creating Auto Scaling Group
# # # resource "aws_autoscaling_group" "lington_docker_prod_ASG" {
# # #   name                      = "lington-docker-prod-ASG"
# # #   max_size                  = 5
# # #   min_size                  = 2
# # #   health_check_grace_period = 240
# # #   health_check_type         = "EC2"
# # #   desired_capacity          = 3
# # #   force_delete              = true
# # #   vpc_zone_identifier       = [aws_subnet.lington-pub1.id, aws_subnet.lington-pub2.id]
# # #   target_group_arns         = [aws_lb_target_group.lington_docker_prod_ALB_TG.arn]
# # #   launch_configuration      = aws_launch_configuration.lington_docker_prod_lconfig.id

# # #   tag {
# # #     key                 = "Name"
# # #     value               = "lington_docker_prod_ASG + 1"
# # #     propagate_at_launch = true
# # #   }
# # # }

# # # # Creating ASG Policy
# # # resource "aws_autoscaling_policy" "Team1-ASG-Policy" {
# # #   autoscaling_group_name = aws_autoscaling_group.lington_docker_prod_ASG.name
# # #   name                   = "lington-docker-prod-ASG-policy"
# # #   policy_type            = "TargetTrackingScaling"

# # #   target_tracking_configuration {
# # #     predefined_metric_specification {
# # #       predefined_metric_type = "ASGAverageCPUUtilization"
# # #     }
# # #     target_value = 60.0
# # #   }
# # # }

# # Create launch template
# resource "aws_launch_template" "lington_docker_prod_launch_template" {
#   name_prefix   = "lington-docker-prod-launch-template"
#   image_id      = aws_ami_from_instance.lington_docker_prod_AMI_image.id
#   instance_type = "t2.micro"
#   key_name                             = aws_key_pair.lington_Key_pub.key_name
#   user_data = local.user_data_ASG
# }

# resource "aws_autoscaling_group" "lington_docker_prod_ASG" {
#   vpc_zone_identifier = [aws_subnet.lington-pub1.id, aws_subnet.lington-pub2.id]
#   desired_capacity   = 3
#   max_size           = 5
#   min_size           = 2

#   launch_template {
#     id      = aws_launch_template.lington_docker_prod_launch_template.id
#     version = "$Latest"
#   }
# }

# # Creating ASG Policy
# resource "aws_autoscaling_policy" "Team1-ASG-Policy" {
#   autoscaling_group_name = aws_autoscaling_group.lington_docker_prod_ASG.name
#   name                   = "lington-docker-prod-ASG-policy"
#   policy_type            = "TargetTrackingScaling"

#   target_tracking_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ASGAverageCPUUtilization"
#     }
#     target_value = 60.0
#   }
# }