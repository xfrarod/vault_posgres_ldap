provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "local_network" {
  name       = "local-network"
  attachable = true
  ipam_config {
    subnet  = "172.18.0.0/16"
    gateway = "172.18.0.1"
  }
}

module "vault" {
  source      = "./modules/vault"
  tag_version = "1.0.0"
  depends_on = [
    docker_network.local_network
  ]
}

module "postgres" {
  source      = "./modules/postgres"
  tag_version = "9"
  depends_on = [
    docker_network.local_network
  ]
}

//module "statsd-exporter" {
//  source      = "./modules/statsd_exporter"
//  tag_version = "v0.18.0"
//  depends_on = [
//    docker_network.local_network
//  ]
//}
//
//module "prometheus" {
//  source      = "./modules/prometheus"
//  tag_version = "v2.21.0"
//  depends_on = [
//    docker_network.local_network
//  ]
//}
//
//module "grafana" {
//  source      = "./modules/grafana"
//  tag_version = "7.2.0-ubuntu"
//  depends_on = [
//    docker_network.local_network
//  ]
//}
