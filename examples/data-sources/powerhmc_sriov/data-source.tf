# Fetch all SR-IOV adapters from the managed system.
# Use adapter_id and physical_port_id from the results when configuring
# sriov_logical_ports on a powerhmc_lpar resource.
data "powerhmc_sriov" "adapters" {
  system_name = "9040-MR9-XXXXXXXX"
}

# Select the first running SR-IOV adapter (Ethernet or RoCE).
locals {
  running_adapters = [
    for a in data.powerhmc_sriov.adapters.adapters :
    a if a.adapter_mode == "Sriov" && a.adapter_state == "Running"
  ]

  # First running adapter (used for downstream references).
  sriov_adapter = local.running_adapters[0]
}

output "sriov_adapters" {
  description = "All SR-IOV adapters on the managed system."
  value       = data.powerhmc_sriov.adapters.adapters
}

output "first_running_adapter_id" {
  description = "adapter_id of the first running SR-IOV adapter."
  value       = local.sriov_adapter.adapter_id
}
