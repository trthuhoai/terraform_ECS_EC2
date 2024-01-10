resource "aws_acm_certificate" "frontend-certificate" {
  count = var.domain_name != "" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "frontend-cert-dns" {
  count = var.domain_name != "" ? 1 : 0
  allow_overwrite = true
  name =  tolist(aws_acm_certificate.frontend-certificate[0].domain_validation_options)[0].resource_record_name
  records = [tolist(aws_acm_certificate.frontend-certificate[0].domain_validation_options)[0].resource_record_value]
  type = tolist(aws_acm_certificate.frontend-certificate[0].domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.selected[0].zone_id
  ttl = 60
}

resource "aws_acm_certificate_validation" "frontend-cert-validate" {
  count = var.domain_name !="" ? 1 : 0
  certificate_arn = aws_acm_certificate.frontend-certificate[0].arn
  validation_record_fqdns = [aws_route53_record.frontend-cert-dns[0].fqdn]
}