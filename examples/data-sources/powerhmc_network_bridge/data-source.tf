# Look up an existing NetworkBridge on a managed system by bridge PVID.
data "powerhmc_network_bridge" "bridge" {
  system_name = "managed-system"
  pvid        = 100
}

output "bridge_id" {
  description = "UUID of the NetworkBridge."
  value       = data.powerhmc_network_bridge.bridge.id
}

output "failover" {
  description = "Whether SEA failover is enabled."
  value       = data.powerhmc_network_bridge.bridge.failover
}

output "load_sharing" {
  description = "Whether load sharing across VIOSes is enabled."
  value       = data.powerhmc_network_bridge.bridge.load_sharing
}

output "primary_vios_sea_name" {
  description = "Device name of the Shared Ethernet Adapter (SEA) on the primary VIOS."
  value       = data.powerhmc_network_bridge.bridge.primary_vios.sea_name
}

output "virtual_networks" {
  description = "Virtual networks attached to this NetworkBridge."
  value       = data.powerhmc_network_bridge.bridge.virtual_network
}