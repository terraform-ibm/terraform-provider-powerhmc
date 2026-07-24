# Network-boot an LPAR (powers the partition on and boots it from a network
# server). Useful for driving an operating-system network installation.
action "powerhmc_lpar_netboot" "boot" {
  config {
    system_name   = "Server-9009-22A-SN123456"
    lpar_name     = "aix-lpar1"
    profile_name  = "default_profile"
    ip_address    = "10.0.0.50" # address assigned to the LPAR during boot
    server_ip     = "10.0.0.10" # TFTP/BOOTP boot server
    gateway       = "10.0.0.1"
    subnet_mask   = "255.255.255.0"
    location_code = "U78AE.001.WZS0225-P1-C9-T1" # network adapter, partial or full

    # Optional network tuning.
    speed         = "auto" # "auto" | "10" | "100" | "1000"
    duplex_mode   = "auto" # "auto" | "full" | "half"
    vlan_priority = 0      # 0-7
    bootp_retries = 5      # 0-9
    tftp_retries  = 5      # 0-9
    timeout       = 25     # minutes to monitor boot progress before treating the reference code as stuck
  }
}
