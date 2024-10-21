resource "nebius_mk8s_v1_cluster" "k8s-cluster" {
  parent_id = var.parent_id
  name      = join("-", ["k8s-lb-test", local.release-suffix])
  control_plane = {
    endpoints = {
      public_endpoint = {}
    }
    etcd_cluster_size = var.etcd_cluster_size
    subnet_id         = var.subnet_id
    version           = var.k8s_version
  }
}

resource "nebius_mk8s_v1_node_group" "cpu-only" {
  fixed_node_count = var.cpu_nodes_count
  parent_id        = nebius_mk8s_v1_cluster.k8s-cluster.id
  name             = join("-", ["k8s-ng-cpu", local.release-suffix])
  labels = {
    "library-solution" : "k8s-lb-test",
  }
  version = var.k8s_version
  template = {
    boot_disk = {
      size_gibibytes = var.cpu_disk_size
      type           = var.cpu_disk_type
    }
    network_interfaces = [
      {
        public_ip_address = null
        subnet_id         = var.subnet_id
      }
    ]
    resources = {
      platform = var.cpu_nodes_platform
      preset   = var.cpu_nodes_preset
    }
    filesystems = null
    underlay_required = false
    cloud_init_user_data = templatefile("./modules/cloud-init/k8s-cloud-init.tftpl", {
      ssh_user_name    = var.ssh_user_name,
      ssh_public_key   = local.ssh_public_key
    })
  }
}

