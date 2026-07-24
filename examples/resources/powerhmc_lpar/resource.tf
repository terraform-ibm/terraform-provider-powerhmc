# The powerhmc_lpar resource creates and manages a Logical Partition (LPAR)
# on an IBM Power Systems managed system. LPARs are immutable: changing any
# managed attribute forces the partition to be destroyed and recreated.

##############################################
# Example 1: LPAR with dedicated processors
##############################################
resource "powerhmc_lpar" "dedicated" {
  system_name = "hmc-zz1"
  lpar_name   = "lpar-dedicated"
  # partition_type accepts "AIX/Linux" or "ibmi".
  partition_type = "AIX/Linux"

  # Memory configuration, in megabytes (MB).
  mem_config = {
    desired = 8192  # 8 GB
    min     = 4096  # 4 GB
    max     = 16384 # 16 GB
  }

  # Dedicated processor modes require desired/min/max_proc.
  proc_config = {
    proc_mode    = "share_idle_procs_active"
    desired_proc = 2
    min_proc     = 1
    max_proc     = 4
  }
}

##############################################
# Example 2: LPAR with shared (uncapped) processors
##############################################
resource "powerhmc_lpar" "shared" {
  system_name    = "hmc-zz1"
  lpar_name      = "lpar-shared"
  partition_type = "AIX/Linux"

  mem_config = {
    desired = 4096
    min     = 2048
    max     = 8192
  }

  # Shared processor modes (cap/uncap) require the virtual processor and
  # processing unit attributes. uncapped_weight (0-255) applies only to uncap.
  proc_config = {
    proc_mode            = "uncap"
    desired_virtual_proc = 2
    min_virtual_proc     = 1
    max_virtual_proc     = 4
    desired_proc_units   = "0.7"
    min_proc_units       = "0.1"
    max_proc_units       = "2.0"
    uncapped_weight      = 100
  }
}

##############################################
# Example 3: LPAR with virtual networks, storage, and fibre channel
##############################################
resource "powerhmc_lpar" "full" {
  system_name    = "hmc-zz1"
  lpar_name      = "lpar-app01"
  profile_name   = "default_profile"
  partition_type = "AIX/Linux"

  mem_config = {
    desired = 8192
    min     = 4096
    max     = 16384
  }

  proc_config = {
    proc_mode            = "uncap"
    desired_virtual_proc = 2
    min_virtual_proc     = 1
    max_virtual_proc     = 4
    desired_proc_units   = "0.5"
    min_proc_units       = "0.1"
    max_proc_units       = "2.0"
  }

  # Attach one or more physical I/O slots by location code. Short (e.g. "C7")
  # or full (e.g. "U78D3.001.WZS078A-P1-C7") location codes are accepted.
  io_slots = ["U78D3.001.WZS078A-P1-C7"]

  # Attach one or more virtual networks. slot_number (2-49) is optional;
  # the HMC auto-assigns a slot when it is omitted.
  virtual_networks = [
    {
      network_name = "app-vlan"
      slot_number  = 3
    }
  ]

  # Attach physical volumes served by one or more VIOS partitions.
  physical_volumes = [
    {
      vios_name        = "vios1"
      phy_volume_names = ["hdisk5", "hdisk6"]
    }
  ]

  # Attach virtual fibre channel adapters mapped to physical VIOS ports.
  # slot_number (2-49) is optional and auto-assigned when omitted.
  virtual_fibre_channels = [
    {
      vios_name = "vios1"
      port_name = "fcs0"
    }
  ]
  # Bound how long Terraform waits for the partition to be created or deleted.
  timeouts {
    create = "30m"
    delete = "20m"
  }
}
