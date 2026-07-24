# Query the current configuration and state of a managed system.
data "powerhmc_sys_config" "server" {
  name = "existing-server-name"
}

output "system_uuid" {
  value = data.powerhmc_sys_config.server.uuid
}

output "system_state" {
  value = data.powerhmc_sys_config.server.state
}

output "system_model" {
  value = data.powerhmc_sys_config.server.machine_type_model
}

output "firmware_version" {
  value = data.powerhmc_sys_config.server.firmware_version
}

output "power_saving_mode" {
  value = data.powerhmc_sys_config.server.power_saving_mode
}
