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

variable "agent_2_enabled" {
  type        = bool
  default     = false
  description = "Whether burst worker agent-2 compute is currently provisioned"
}

variable "agent_2_image" {
  type        = string
  default     = "debian-12"
  description = "Image name or Hetzner snapshot ID used when creating agent-2"
}

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
  for_each = {
    for name, host in local.fleet : name => host
    if !try(host.ephemeral, false) || (name == "agent-2" && var.agent_2_enabled)
  }

  name        = each.key
  image       = each.key == "agent-2" ? var.agent_2_image : each.value.image
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

resource "hcloud_volume" "agent_2_data" {
  name              = "agent-2-data"
  size              = 250
  location          = "nbg1"
  format            = "ext4"
  delete_protection = true
  labels            = local.labels

  lifecycle {
    prevent_destroy = true
  }
}

resource "hcloud_volume_attachment" "agent_2_data" {
  count     = var.agent_2_enabled ? 1 : 0
  volume_id = hcloud_volume.agent_2_data.id
  server_id = hcloud_server.fleet["agent-2"].id
  automount = false
}

output "server_ips" {
  description = "Public IPv4 address for each fleet server"
  value = {
    for name, server in hcloud_server.fleet : name => server.ipv4_address
  }
}

output "agent_2_enabled" {
  description = "Whether burst worker agent-2 compute is currently provisioned"
  value       = var.agent_2_enabled
}

output "agent_2_volume_id" {
  description = "Hetzner volume ID of the persistent agent-2-data volume"
  value       = hcloud_volume.agent_2_data.id
}
