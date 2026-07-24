# Power an LPAR or VIOS partition on or off.

# Power on an AIX/Linux LPAR with a boot mode.
action "powerhmc_partition_power_on_off" "aix_on" {
  config {
    system_name    = "Server-9009-22A-SN123456"
    partition_name = "aix-lpar1"
    partition_type = "lpar" # "lpar" | "vios"
    action         = "poweron"
    boot_mode      = "norm" # "norm" | "dd" | "ds" | "of" | "sms" (AIX/Linux only)
    keylock        = "norm" # "manual" | "norm"
  }
}

# Power on an IBM i (OS400) LPAR. IBM i requires ipl_source and does NOT
# accept boot_mode (the two are mutually exclusive).
action "powerhmc_partition_power_on_off" "ibmi_on" {
  config {
    system_name    = "Server-9009-22A-SN123456"
    partition_name = "ibmi-lpar1"
    partition_type = "lpar"
    action         = "poweron"
    ipl_source     = "a" # "a" | "b" | "c" | "d"
  }
}

# Power off a VIOS partition and restart it.
action "powerhmc_partition_power_on_off" "vios_off" {
  config {
    system_name    = "Server-9009-22A-SN123456"
    partition_name = "vios1"
    partition_type = "vios"
    action         = "poweroff"
    shutdown_mode  = "shutdown" # "shutdown" | "osshutdown" | "dumprestart"
    force_shutdown = true
    restart        = true
    timeout        = 30 # minutes; bounds how long the provider waits (min 1, default 60)
  }
}
