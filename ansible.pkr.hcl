variable "login_username" {
  type    = string
  default = "${env("PUSH_LOGIN_USERNAME")}"
}
variable "login_password" {
  type    = string
  default = "${env("PUSH_LOGIN_PASSWORD")}"
}

source "docker" "bullseye" {
  image       = "debian:bullseye-backports"
  export_path = "bullseye.tar"
}

source "docker" "bookworm" {
  image       = "debian:bookworm-backports"
  export_path = "bookworm.tar"
}

build {
  sources = [
    "source.docker.bullseye"
  ]
  provisioner "shell" {
    inline = [
      "apt-get update -y",
      "apt-get upgrade -y",
      "apt-get install -y --no-install-recommends ansible -t bullseye-backports",
      "apt-get autoremove",
      "apt-get autoclean",
    ]
  }
  post-processors {
    post-processor "docker-import" {
      repository = "wate/ansible"
      tag        = "latest"
    }
    post-processor "docker-push" {
      keep_input_artifact = false
      login               = true
      login_username      = "${var.login_username}"
      login_password      = "${var.login_password}"
    }
  }
}