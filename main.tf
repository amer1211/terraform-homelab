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
    force_path_style            = true
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

data "hcloud_ssh_key" "default" {
  name = "terraform-homelab"
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
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Deployed with Terraform!</h1>" > /var/www/html/index.html
  EOF

  labels = {
    project     = "terraform-homelab"
    environment = "dev"
  }
}
