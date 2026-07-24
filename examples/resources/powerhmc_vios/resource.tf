# The powerhmc_vios resource creates and manages a Virtual I/O Server (VIOS)
# partition on an IBM Power Systems managed system. VIOS partitions are
# immutable: changing any managed attribute forces destroy and recreate.

##############################################
# Example 1: VIOS with dedicated processors
##############################################
resource "powerhmc_vios" "dedicated" {
  system_name  = "PowerSystem1"
  vios_name    = "vios1"
  profile_name = "default_profile"

  # Memory configuration, in megabytes (MB).
  mem_config = {
    desired = 8192
    min     = 4096
    max     = 16384
  }

  # Dedicated processor modes require desired/min/max_proc.
  proc_config = {
    proc_mode    = "keep_idle_procs"
    desired_proc = 2
    min_proc     = 1
    max_proc     = 4
  }

  # Physical I/O slot device locations to assign to the VIOS.
  io_slots = ["C18-L1-T1", "C19-L1-T1"]
}

##############################################
# Example 2: VIOS with shared (uncapped) processors
##############################################
resource "powerhmc_vios" "shared" {
  system_name = "PowerSystem1"
  vios_name   = "vios2"

  mem_config = {
    desired = 4096
    min     = 2048
    max     = 8192
  }

  # Shared processor modes (cap/uncap) require virtual processor and
  # processing unit attributes.
  proc_config = {
    proc_mode            = "uncap"
    desired_virtual_proc = 2
    min_virtual_proc     = 1
    max_virtual_proc     = 4
    desired_proc_units   = "0.5"
    min_proc_units       = "0.1"
    max_proc_units       = "2.0"
    shared_proc_pool_id  = 0
  }

  # Bound how long Terraform waits for the VIOS to be created or deleted.
  timeouts {
    create = "30m"
    delete = "20m"
  }
}
