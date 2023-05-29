
# Create Route 53
data "aws_route53_zone" "petadopt_hosted_zone" {
  name         = var.domain_name
  private_zone = false
 
} 


# Create record and point to docker production load balancer; connecting the java application load balancer to my domain name
resource "aws_route53_record" "petadopt_A_record" {
  zone_id = data.aws_route53_zone.petadopt_hosted_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.lington_docker_prod_ALB.dns_name
    zone_id                = aws_lb.lington_docker_prod_ALB.zone_id
    evaluate_target_health = true
  }
}

#Create certificate which is dependent on having a domain name
resource "aws_acm_certificate" "petadopt-cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Environment = "production"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Attaching route 53 and certificate, CONNECTING ROUTE 53 TO THE CERTIFICATE
resource "aws_route53_record" "pedadopt-project" {
  for_each = {
    for anybody in aws_acm_certificate.petadopt-cert.domain_validation_options : anybody.domain_name => {
      name   = anybody.resource_record_name
      record = anybody.resource_record_value
      type   = anybody.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.petadopt_hosted_zone.zone_id
}

#sign our certificate
resource "aws_acm_certificate_validation" "sign_cert" {
  certificate_arn         = aws_acm_certificate.petadopt-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.pedadopt-project : record.fqdn]
}

# # Create Route 53
# resource "aws_route53_zone" "hosted_zone" {
#   name = var.domain_name
#   tags = {
#     Environment = "hosted_zone"
#   }
# } 

# # Create record and point to docker production load balancer; connecting the java application load balancer to my domain name
# resource "aws_route53_record" "petadopt_A_record" {
#   zone_id = aws_route53_zone.petadopt_hosted_zone.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_lb.lington_docker_prod_ALB.dns_name
#     zone_id                = aws_lb.lington_docker_prod_ALB.zone_id
#     evaluate_target_health = true
#   }
# }