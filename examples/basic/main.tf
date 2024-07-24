data "talos_client_configuration" "this" {
  cluster_name         = module.cluster.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = module.cluster.controlplane_ip_addresses
  nodes                = module.cluster.node_ip_addresses
}

resource "talos_machine_secrets" "this" {}

module "cluster" {
  source = "../.."

  talos_version = "v1.7.5"

  datastore_id = "nvme-data"

  workers = {
    default = {
      node_count        = 3
      memory_size_in_mb = 4096
      tags              = ["worker"]
    }
  }

  machine_secrets = talos_machine_secrets.this
  metrics_server  = true

  tags = ["kubernetes", "basic-example"]
}

resource "local_file" "kubeconfig" {
  content  = module.cluster.kubeconfig_raw
  filename = "kubeconfig"
}

resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "talosconfig"
}
