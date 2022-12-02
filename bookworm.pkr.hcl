variable "login_username" {
  type    = string
  default = "${env("PUSH_LOGIN_USERNAME")}"
}
variable "login_password" {
  type    = string
  default = "${env("PUSH_LOGIN_PASSWORD")}"
}

source "docker" "bookworm" {
  image       = "debian:bookworm-backports"
  export_path = "bookworm.tar"
  changes = [
    "VOLUME [\"/sys/fs/cgroup\"]",
    "CMD [\"/lib/systemd/systemd\"]",
  ]
}

build {
  sources = [
    "source.docker.bookworm",
  ]
  provisioner "shell" {
    inline = [
      "apt-get update -y",
      "apt-get upgrade -y",
      "apt-get install -y --no-install-recommends systemd",
      "apt-get autoremove",
      "apt-get autoclean",
      "apt-get clean",
      "rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*",
      "rm -f /lib/systemd/system/multi-user.target.wants/*",
      "rm -f /etc/systemd/system/*.wants/*",
      "rm -f /lib/systemd/system/multi-user.target.wants/*",
      "rm -f /lib/systemd/system/local-fs.target.wants/*",
      "rm -f /lib/systemd/system/sockets.target.wants/*initctl*",
      "rm -f /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup*",
      "rm -f /lib/systemd/system/systemd-update-utmp*",
    ]
  }
  post-processors {
    post-processor "docker-import" {
      repository = "wate/bookworm"
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