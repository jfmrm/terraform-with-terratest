output "instance_id" {
  value = module.ec2_cluster.id
}

output "lb_dns" {
  value = module.alb.this_lb_dns_name
}
