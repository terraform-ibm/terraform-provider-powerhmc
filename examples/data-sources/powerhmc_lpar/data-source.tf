# Look up an existing LPAR by managed system and partition name.
data "powerhmc_lpar" "my_lpar" {
  system_name = "my-managed-system"
  lpar_name   = "lpar1"
}

output "lpar_uuid" {
  value = data.powerhmc_lpar.my_lpar.lpar_uuid
}

output "lpar_state" {
  value = data.powerhmc_lpar.my_lpar.state
}

output "lpar_processor_mode" {
  value = data.powerhmc_lpar.my_lpar.proc_config.proc_mode
}

output "lpar_virtual_networks" {
  value = data.powerhmc_lpar.my_lpar.virtual_networks
}
