terraform {
  required_version = ">= 1.10"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.66.1"
    }
  }
}

provider "hcloud" {}

locals {
  fleet = jsondecode(file("${path.module}/nix/fleet.json"))
  labels = {
    fleet      = "agent-fleet"
    managed_by = "opentofu"
  }
}

resource "hcloud_ssh_key" "fleet" {
  name       = "agent-fleet"
  public_key = file("${path.module}/ssh/id_ed25519.pub")
  labels     = local.labels
}

resource "hcloud_firewall" "fleet" {
  name   = "agent-fleet"
  labels = local.labels

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22000"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "22000"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }
}

resource "hcloud_server" "fleet" {
  for_each = local.fleet

  name        = each.key
  image       = each.value.image
  server_type = each.value.serverType
  location    = each.value.location
  labels      = local.labels

  ssh_keys     = [hcloud_ssh_key.fleet.id]
  firewall_ids = [hcloud_firewall.fleet.id]
}

output "server_ips" {
  description = "Public IPv4 address for each fleet server"
  value = {
    for name, server in hcloud_server.fleet : name => server.ipv4_address
  }
}
