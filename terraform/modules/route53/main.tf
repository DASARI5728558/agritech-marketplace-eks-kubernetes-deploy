resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0
  name  = var.dns_zone_name
  tags  = var.tags
}

data "aws_route53_zone" "existing" {
  count = var.create_zone ? 0 : 1
  name  = var.dns_zone_name
}

locals {
  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

resource "aws_route53_record" "app" {
  zone_id = local.zone_id
  name    = var.record_name
  type    = "CNAME"
  ttl     = 300
  records = [var.load_balancer_dns_name]
}
