terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
  }

  backend "s3" {
    bucket = "terraform-state-bucket-amer"
    key    = "terraform.tfstate"
    region = "nbg1"
    endpoints = {
      s3 = "https://nbg1.your-objectstorage.com"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

data "hcloud_ssh_key" "default" {
  name = "desktop-key"
}

resource "hcloud_firewall" "web" {
  name = "web-firewall"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "9090"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "3000"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "web" {
  name        = var.server_name
  server_type = var.server_type
  image       = "ubuntu-22.04"
  location    = var.location

  ssh_keys     = [data.hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.web.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e

    apt-get update -y
    apt-get upgrade -y

    curl -fsSL https://get.docker.com | sh

    systemctl enable docker
    systemctl start docker

    echo "Docker ready" > /var/log/cloud-init-done.log
  EOF

  labels = {
    project     = "terraform-homelab"
    environment = "dev"
  }
}
