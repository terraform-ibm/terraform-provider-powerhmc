# The powerhmc_sys_config resource manages the configuration of an EXISTING
# managed system (CEC). It cannot create or physically delete a system:
#
#   * You MUST `terraform import` the system before applying (see examples/resources/powerhmc_sys_config/import.sh).
#   * Deleting the resource only removes it from Terraform state.
#
# Some settings only take effect after the next system power-on or restart,
# and requested_huge_pages can only be changed while the system is powered off.

resource "powerhmc_sys_config" "server" {
  name = "existing-server-name" # must match the imported system name

  # requested_huge_pages can only be changed while the system is powered off;
  # a plan that changes it on a running system is rejected.
  requested_huge_pages       = 100
  mem_mirroring_mode         = "system firmware only" # "none" | "system firmware only"
  mem_region_size            = "256"
  power_on_lpar_start_policy = "autostart" # "autorecovery" | "autostart" | "userinit"
  power_off_policy           = false
  power_saving_mode          = "Maximum_Performance"

  # Bound how long Terraform waits for the configuration update to apply.
  timeouts {
    update = "20m"
  }
}
