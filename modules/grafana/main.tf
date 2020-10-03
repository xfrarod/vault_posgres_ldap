variable "tag_version" {}

resource "docker_image" "this" {
  name         = "grafana/grafana:${var.tag_version}"
  keep_locally = true
}

resource "docker_container" "grafana" {
  name     = "grafana"
  image    = docker_image.this.name
  must_run = true
  networks_advanced {
    name         = "local-network"
  }
  ports {
    internal = "3000"
    external = "3000"
    protocol = "tcp"
  }
  upload {
    content = file("${path.cwd}/grafana/grafana.ini")
    file    = "/etc/grafana/grafana.ini"
  }
  volumes {
    host_path      = "${path.cwd}/grafana/provisioning/datasources"
    container_path = "/etc/grafana/provisioning/datasources"
  }
}
