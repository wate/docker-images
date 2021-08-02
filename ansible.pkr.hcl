variable "login_username" {
  type    = string
  default = "${env("PUSH_LOGIN_USERNAME")}"
}
variable "login_password" {
  type    = string
  default = "${env("PUSH_LOGIN_PASSWORD")}"
}

source "docker" "buster" {
  image       = "debian:buster-backports"
  export_path = "ansible.tar"
}

build {
  sources = [
    "source.docker.buster"
  ]
  provisioner "shell" {
    inline = [
      "apt -y update",
      "apt install -y --no-install-recommends ansible -t buster-backports"
    ]
  }
  post-processors {
    post-processor "docker-import" {
      repository = "wate/ansible"
    }
    post-processor "docker-push" { 
      keep_input_artifact = false
      login = true
      login_username = "${var.login_username}"
      login_password = "${var.login_password}"
    }
  }
}