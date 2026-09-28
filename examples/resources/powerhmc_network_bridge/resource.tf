# The powerhmc_network_bridge resource creates and manages a NetworkBridge
# (Shared Ethernet Adapter) and its associated VirtualNetworks on an IBM Power
# Systems managed system.
#
# Both `virtual_network` and `sea` must always be configured together.
# Exactly one virtual_network entry must have `tagged = false` — its VLAN ID
# becomes the bridge PVID.
#
# Import: terraform import powerhmc_network_bridge.<name> <system_name>/<bridge_pvid>
# (see import.sh)

##############################################
# Example 1: Basic bridge — single VIOS, one untagged + one tagged VN
##############################################
resource "powerhmc_network_bridge" "basic" {
  system_name = "managed-system"

  virtual_network = [
    {
      name           = "vn-untagged"
      virtual_switch = "ETHERNET0"
      vlan_id        = 145
      tagged         = false
    },
    {
      name           = "vn-tagged"
      virtual_switch = "ETHERNET0"
      vlan_id        = 200
      tagged         = true
    },
  ]

  sea {
    primary_vios {
      name            = "vios1"
      backing_adapter = "ent0"
    }
  }
}

##############################################
# Example 2: Bridge with failover (secondary VIOS)
##############################################
resource "powerhmc_network_bridge" "failover" {
  system_name = "managed-system"

  virtual_network = [
    {
      name           = "vn-untagged"
      virtual_switch = "ETHERNET0"
      vlan_id        = 145
      tagged         = false
    },
    {
      name           = "vn-app"
      virtual_switch = "ETHERNET0"
      vlan_id        = 300
      tagged         = true
    },
  ]

  sea {
    jumbo_frame = false
    large_send  = false
    qos_mode    = "disabled" # "disabled" | "strict" | "loose"

    primary_vios {
      name            = "vios1"
      backing_adapter = "ent0"
    }

    secondary_vios {
      name            = "vios2"
      backing_adapter = "ent0"
    }
  }
}

##############################################
# Example 3: Bridge with load sharing and explicit load groups
##############################################
resource "powerhmc_network_bridge" "load_sharing" {
  system_name = "managed-system"

  virtual_network = [
    {
      name           = "vn-untagged"
      virtual_switch = "ETHERNET0"
      vlan_id        = 145
      tagged         = false
    },
    {
      name           = "vn-app"
      virtual_switch = "ETHERNET0"
      vlan_id        = 200
      tagged         = true
    },
    {
      name           = "vn-db"
      virtual_switch = "ETHERNET0"
      vlan_id        = 300
      tagged         = true
    },
  ]

  sea {
    load_sharing = true

    # Each load_group maps a trunk-adapter port VLAN (pvid) to a set of
    # virtual networks (vlan_ids). The pvid must be distinct from all
    # virtual_network vlan_id values.
    load_group = [
      {
        pvid     = 50
        vlan_ids = [200]
      },
      {
        pvid     = 51
        vlan_ids = [300]
      },
    ]

    primary_vios {
      name            = "vios1"
      backing_adapter = "ent0"
    }

    secondary_vios {
      name            = "vios2"
      backing_adapter = "ent0"
    }
  }

  timeouts {
    create = "15m"
    update = "20m"
    delete = "10m"
  }
}
