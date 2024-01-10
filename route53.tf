data "aws_route53_zone" "selected" {
  count        = var.domain_name != "" ? 1 : 0
  name         = var.root_domain_name
  private_zone = false
}

resource "aws_route53_record" "frontend-record" {
  count   = var.domain_name != "" ? 1 : 0
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
