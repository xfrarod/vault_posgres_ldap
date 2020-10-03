variable "tag_version" {}

data "template_file" "configuration" {
  template = (file("${path.cwd}/statsd_mapping.conf"))
}

resource "docker_image" "this" {
  name         = "prom/statsd-exporter:${var.tag_version}"
  keep_locally = true
}

resource "docker_container" "statsd_exporter" {
  name     = "statsd_exporter"
  image    = docker_image.this.name
  command  = ["--statsd.mapping-config=/tmp/statsd_mapping.conf"]
  must_run = true
  networks_advanced {
    name         = "local-network"
  }
  ports {
    internal = "9125"
    external = "9125"
    protocol = "tcp"
  }
    ports {
    internal = "9125"
    external = "9125"
    protocol = "udp"
  }
    ports {
    internal = "9102"
    external = "9102"
    protocol = "tcp"
  }
  upload {
    content = data.template_file.configuration.rendered
    file    = "/tmp/statsd_mapping.conf"
  }
}
