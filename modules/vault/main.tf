variable "tag_version" {}

data "template_file" "configuration" {
  template = (file("${path.cwd}/vault/config/config.hcl"))
}

resource "docker_image" "this" {
  name         = "vault:${var.tag_version}"
  keep_locally = true
}

resource "docker_container" "vault" {
  name     = "vault"
  hostname = "vault"
  image    = docker_image.this.name
  env = ["VAULT_ADDR=http://127.0.0.1:8200",
    "KEY1=Rz7nccNNLEE0e0W+yQPB6KrATAMmNmuUGYGHaS6aMhBe",
    "KEY2=OIHfdY93utohv4EyZaMS8FDTyjTzmay4UrSNghF5LOTl",
    "KEY3=iYTOc19DXO/lJhoui4Xf+U9Eic1IkOkLL9cz4I246pPG",
    "KEY4=30vVo6EqJ0bXv6d4DGLS3ql127FqQc37Y7l8hFI87v6v",
    "KEY5=bwPEaO85ixhLnTnAtJ4lPkbo+96U/GzzLOUxDXee6b4Z",
    "ROOT_TOKEN=5d9e40a3-eb45-7e9b-53ff-e32a70dfabe0"
  ]
  entrypoint = ["vault", "server", "-config=/vault/config"]
  must_run   = true
  capabilities {
    add = ["IPC_LOCK"]
  }
  healthcheck {
    test         = ["CMD", "vault", "status"]
    interval     = "10s"
    timeout      = "2s"
    start_period = "10s"
    retries      = 2
  }
  networks_advanced {
    name = "local-network"
  }
  ports {
    internal = "8200"
    external = "8200"
    protocol = "tcp"
  }
  upload {
    content = data.template_file.configuration.rendered
    file    = "/vault/config/main.hcl"
  }
  volumes {
    host_path      = "${path.cwd}/vault/data"
    container_path = "/vault/data"
  }
  volumes {
    host_path      = "${path.cwd}/vault/logs"
    container_path = "/vault/logs"
  }
}
