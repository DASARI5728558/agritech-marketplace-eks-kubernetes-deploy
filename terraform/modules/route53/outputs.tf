output "zone_id" {
  value = local.zone_id
}

output "name_servers" {
  value = var.create_zone ? aws_route53_zone.this[0].name_servers : data.aws_route53_zone.existing[0].name_servers
}

output "fqdn" {
  value = "${var.record_name}.${var.dns_zone_name}"
}
