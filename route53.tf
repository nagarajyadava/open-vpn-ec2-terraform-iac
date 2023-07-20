resource "aws_route53_zone" "openvpn-cloud" {
  name = "apps.openvpn.cloud"
}

resource "aws_route53_record" "openvpn-record" {
  zone_id = aws_route53_zone.openvpn-cloud.zone_id
  name    = "openvpn.apps.openvpn.cloud"
  type    = "A"
  alias {
    name                   = aws_alb.openvpn-lb.dns_name
    zone_id                = aws_alb.openvpn-lb.zone_id
    evaluate_target_health = true
  }
}

output "ns-servers" {
  value = aws_route53_zone.openvpn-cloud.name_servers
}

resource "aws_acm_certificate" "app_certificate" {
  domain_name       = "*.apps.openvpn.cloud"
  validation_method = "DNS"

  tags = {
    Name = "openvpn-cloud-certificate"
  }
}

resource "aws_route53_record" "certificate_verification" {
  zone_id = aws_route53_zone.openvpn-cloud.zone_id
  name    = tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 300

  # Ensure the record is associated with the certificate's validation domain
  allow_overwrite = true
}