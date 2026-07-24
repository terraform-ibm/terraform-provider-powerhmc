# Install VIOS onto a partition from an image already staged on the HMC.
# The installation image must exist on the HMC at:
#   /extra/viosimages/<image_source>/<image_name>.iso
action "powerhmc_vios_install" "install" {
  config {
    system_name       = "Server-9009-22A-SN123456"
    vios_name         = "vios1"
    profile_name      = "default_profile"
    installation_type = "image"              # only "image" is supported
    image_source      = "installation_image" # directory name under /extra/viosimages/

    # Network configuration for the installation path.
    ip_address  = "10.0.0.60"
    subnet_mask = "255.255.255.0"
    gateway     = "10.0.0.1"
    boot_device = "U78AE.001.WZS0225-P1-C18-L1-T1" # adapter location code

    # Optional tuning.
    speed          = "1000" # "10" | "100" | "1000"
    duplex_mode    = "full" # "auto" | "full" | "half"
    vlan_tag       = 0      # 0-4094
    vlan_priority  = 0      # 0-7
    tftp_retries   = 5      # 0-9
    bootp_retries  = 5      # 0-9
    timeout        = 150    # minutes, at least 30
    license_accept = true
  }
}
