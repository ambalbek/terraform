# Configure the Docker provider
provider "docker" {
  host = "tcp://127.0.0.1:8080"
}

# Create a container
resource "docker_container" "foo" {
  image = "${docker_image.ubuntu.latest}"
  name  = "foo"
}

resource "docker_image" "ubuntu" {
  name = "ubuntu:latest"
}