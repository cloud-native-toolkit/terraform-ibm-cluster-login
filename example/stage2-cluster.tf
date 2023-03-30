module "cluster" {
  source = "../"

  resource_group_name = var.resource_group_name
  region = var.region
  name = var.cluster_name
  name_prefix = var.name_prefix
}

resource local_file output {
  filename = "output.txt"

  content = jsonencode({
    id = module.cluster.id
    name = module.cluster.name
    resource_group_name = module.cluster.resource_group_name
    region = module.cluster.region
    platform = module.cluster.platform
  })
}
