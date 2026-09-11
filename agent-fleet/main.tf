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

# Only these ports are reachable on fleet servers; everything else is dropped.
# 0.0.0.0/0 + ::/0 = open to the whole internet (Hetzner servers get IPv4 and IPv6).
resource "hcloud_firewall" "fleet" {
  name   = "agent-fleet"
  labels = local.labels

  # SSH access.
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  # Syncthing sync protocol (TCP for reliability, UDP for speed + discovery).
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

  # Tailscale's default WireGuard port, so peers can connect directly
  # instead of relaying through DERP.
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "41641"
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

resource "hcloud_volume" "agent_1_home" {
  name              = "agent-1-home"
  size              = 250
  server_id         = hcloud_server.fleet["agent-1"].id
  automount         = false
  delete_protection = true
  labels            = local.labels

  lifecycle {
    prevent_destroy = true
  }
}

output "server_ips" {
  description = "Public IPv4 address for each fleet server"
  value = {
    for name, server in hcloud_server.fleet : name => server.ipv4_address
  }
}
