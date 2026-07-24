---
page_title: "Actions: Power Control, Network Boot, and VIOS Install"
subcategory: "Guides"
description: |-
  Use provider actions to power partitions and systems on and off, network-boot an LPAR, and install VIOS.
---

# Actions

Resources describe the *desired configuration* of your IBM Power infrastructure.
Some operations, though, are **imperative** — powering a partition on, network
booting an LPAR, installing VIOS. The provider models these as
**[actions](https://developer.hashicorp.com/terraform/language/actions)**, a
Terraform feature for invoking one-off operations at lifecycle events.

-> **Actions require Terraform v1.14 or later.**

## Available actions

| Action | What it does |
|---|---|
| [`powerhmc_sys_on_off`](../actions/sys_on_off.md) | Powers a whole managed system (CEC) on or off. |
| [`powerhmc_partition_power_on_off`](../actions/partition_power_on_off.md) | Powers an individual LPAR or VIOS partition on or off. |
| [`powerhmc_lpar_netboot`](../actions/lpar_netboot.md) | Powers on an LPAR and boots it from a network server. |
| [`powerhmc_vios_install`](../actions/vios_install.md) | Installs VIOS onto a partition from an image staged on the HMC. |

~> **Two power actions, two scopes.** `powerhmc_sys_on_off` operates on the
**managed system** (the whole CEC). `powerhmc_partition_power_on_off` operates on
a **single LPAR or VIOS**. Pick the one that matches your target.

## How actions are declared and triggered

An action is declared with an `action` block, and *invoked* by referencing it
from a resource's `lifecycle { action_trigger { … } }` block. The action runs
when the named lifecycle event fires.

```terraform
# 1. Declare the action and its configuration.
action "powerhmc_partition_power_on_off" "power_on" {
  config {
    system_name    = "Server-9009-22A-SN123456"
    partition_name = "app01"
    partition_type = "lpar"
    action         = "poweron"
  }
}

# 2. Trigger it from a resource lifecycle event.
resource "powerhmc_lpar" "app01" {
  system_name    = "Server-9009-22A-SN123456"
  lpar_name      = "app01"
  partition_type = "AIX/Linux"

  mem_config = {
    desired = 4096
    min     = 2048
    max     = 8192
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

  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.powerhmc_partition_power_on_off.power_on]
    }
  }
}
```

Common lifecycle events are `after_create`, `after_update`, and `before_destroy`.

## Example: provision and network-boot an LPAR

Create an LPAR, then network-boot it to start an operating-system installation:

```terraform
resource "powerhmc_lpar" "aix01" {
  system_name    = "Server-9009-22A-SN123456"
  lpar_name      = "aix01"
  partition_type = "AIX/Linux"

  mem_config = {
    desired = 8192
    min     = 4096
    max     = 16384
  }

  proc_config = {
    proc_mode    = "share_idle_procs_active"
    desired_proc = 2
    min_proc     = 1
    max_proc     = 4
  }

  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.powerhmc_lpar_netboot.boot]
    }
  }
}

action "powerhmc_lpar_netboot" "boot" {
  config {
    system_name   = powerhmc_lpar.aix01.system_name
    lpar_name     = powerhmc_lpar.aix01.lpar_name
    ip_address    = "10.0.0.50"
    server_ip     = "10.0.0.10"
    gateway       = "10.0.0.1"
    subnet_mask   = "255.255.255.0"
    location_code = "U78AE.001.WZS0225-P1-C9-T1"
  }
}
```

## Example: power-cycle a managed system

Trigger a managed-system restart when a configuration change requires it. Note
that for `powerhmc_sys_on_off`, `restart` requires `immed = true`:

```terraform
resource "powerhmc_sys_config" "server" {
  name               = "Server-9009-22A-SN123456"
  mem_mirroring_mode = "system firmware only"

  lifecycle {
    action_trigger {
      events  = [after_update]
      actions = [action.powerhmc_sys_on_off.restart]
    }
  }
}

action "powerhmc_sys_on_off" "restart" {
  config {
    name      = "Server-9009-22A-SN123456"
    operation = "off"
    immed     = true
    restart   = true
    timeout   = 30
  }
}
```

## Provider-scoped actions

Actions honor provider aliasing, so you can drive several HMCs from one
configuration:

```terraform
provider "powerhmc" {
  alias = "site_a"
  host  = "hmc-a.example.com"
  # ...
}

action "powerhmc_sys_on_off" "site_a_off" {
  provider = powerhmc.site_a
  config {
    name      = "Server-9009-22A-SN123456"
    operation = "off"
  }
}
```

See each action's reference page for its complete argument list and validation
rules:

* [`powerhmc_sys_on_off`](../actions/sys_on_off.md)
* [`powerhmc_partition_power_on_off`](../actions/partition_power_on_off.md)
* [`powerhmc_lpar_netboot`](../actions/lpar_netboot.md)
* [`powerhmc_vios_install`](../actions/vios_install.md)
