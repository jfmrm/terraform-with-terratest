output "instances_ids" {
  value = module.tags_cluster.instance_id
}

output "lb_public_ip" {
  value = module.alb.public_ip
}
