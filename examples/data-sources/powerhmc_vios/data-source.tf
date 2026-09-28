# Look up an existing VIOS partition by managed system and VIOS name.
data "powerhmc_vios" "my_vios" {
  system_name = "my-managed-system"
  vios_name   = "vios1"
}

output "vios_uuid" {
  value = data.powerhmc_vios.my_vios.vios_uuid
}

output "vios_state" {
  value = data.powerhmc_vios.my_vios.state
}

output "vios_ip_address" {
  value = data.powerhmc_vios.my_vios.ip_address
}

output "vios_memory" {
  value = data.powerhmc_vios.my_vios.mem_config
}

# Free Ethernet adapters that can be used as SEA backing devices.
output "free_sea_devices" {
  value = data.powerhmc_vios.my_vios.free_sea_devices
}
