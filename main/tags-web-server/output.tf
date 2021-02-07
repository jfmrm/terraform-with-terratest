output "instances_ids" {
  value = module.tags_cluster.instance_id
}

output "lb_dns" {
  value = module.tags_cluster.lb_dns
}
