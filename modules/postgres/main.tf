variable "tag_version" {
  default = "9"
}

resource "docker_image" "this" {
  name         = "postgres:${var.tag_version}"
  keep_locally = true
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = docker_image.this.name
  env = ["POSTGRES_DB=myapp",
    "POSTGRES_USER=postgres",
  "POSTGRES_PASSWORD=postgres"]

  ports {
    internal = "5432"
    external = "5432"
    protocol = "tcp"
  }
  networks_advanced {
    name = "local-network"
  }
}