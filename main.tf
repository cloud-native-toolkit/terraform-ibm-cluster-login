
locals {
  name_prefix      = var.name_prefix != "" ? var.name_prefix : var.resource_group_name
  name_list        = [local.name_prefix, "cluster"]
  cluster_name     = var.name != "" ? var.name : join("-", local.name_list)
  cluster_config   = lookup(data.ibm_container_cluster_config.cluster_admin, "config_file_path", "")

  server_url        = lookup(data.ibm_container_vpc_cluster.config, "public_service_endpoint_url", "")
  ingress_hostname  = lookup(data.ibm_container_vpc_cluster.config, "ingress_hostname", "")
  tls_secret        = lookup(data.ibm_container_vpc_cluster.config, "ingress_secret", "")
  kube_version      = lookup(data.ibm_container_vpc_cluster.config, "kube_version", "")
  cluster_type      = length(regexall(".*_openshift", local.kube_version)) > 0 ? "openshift" : "kubernetes"
  # value should be ocp4, ocp3, or kubernetes
  cluster_type_code = local.cluster_type == "openshift" ? "ocp4" : "iks"
  cluster_type_tag  = local.cluster_type == "openshift" ? "ocp" : "iks"
  cluster_version   = regex("([0-9]+[.][0-9]+[.][0-9]+).*", local.kube_version)[0]
}

resource null_resource print_resources {
  provisioner "local-exec" {
    command = "echo 'Resource group: ${var.resource_group_name}'"
  }
}

data ibm_resource_group resource_group {
  depends_on = [null_resource.print_resources]

  name = var.resource_group_name
}

data external dirs {
  program = ["bash", "${path.module}/scripts/create-dirs.sh"]

  query = {
    tmp_dir = "${path.cwd}/.tmp"
    cluster_config_dir = "${path.cwd}/.kube"
  }
}

data clis_check clis {
  clis = ["jq", "kubectl"]
}

data ibm_container_vpc_cluster config {
  name              = local.cluster_name
  alb_type          = var.disable_public_endpoint ? "private" : "public"
  resource_group_id = data.ibm_resource_group.resource_group.id
}

data ibm_container_cluster_config cluster_admin {
  cluster_name_id   = local.cluster_name
  admin             = true
  resource_group_id = data.ibm_resource_group.resource_group.id
  config_dir        = data.external.dirs.result.cluster_config_dir
}
