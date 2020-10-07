variable "tag_version" {}

data "template_file" "configuration" {
  template = (file("${path.cwd}/prometheus.yml"))
}

resource "docker_image" "this" {
  name         = "prom/prometheus:${var.tag_version}"
  keep_locally = true
}

resource "docker_container" "prometheus" {
  name     = "prometheus"
  image    = docker_image.this.name
  command  = ["--config.file=/tmp/prometheus.yml"]
  must_run = true
  networks_advanced {
    name = "local-network"
  }
  ports {
    internal = "9090"
    external = "9090"
    protocol = "tcp"
  }
  upload {
    content = data.template_file.configuration.rendered
    file    = "/tmp/prometheus.yml"
  }
}
