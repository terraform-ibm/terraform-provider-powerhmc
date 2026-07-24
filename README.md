# IBM Terraform Provider for Power Hardware Management Console

## Overview

The IBM Power Systems HMC Terraform Provider enables you to manage and automate IBM Power Systems environments through the Power Hardware Management Console (HMC) using Terraform. This provider exposes reusable Terraform resources and data sources that allow customers to define, provision, and manage Power systems and HMC configurations in a declarative and repeatable manner. By integrating HMC management into the Terraform ecosystem, enterprises can incorporate IBM Power infrastructure into modern Infrastructure as Code (IaC) workflows.

## Purpose

The primary goal of this provider is to make IBM Power infrastructure management more seamless within enterprise automation strategies. It enables Power platform operations to be versioned, validated, and deployed consistently alongside the rest of an organization's infrastructure, helping organizations adopt a unified Infrastructure as Code approach.

## Requirements

- Terraform 1.0 or later
- IBM Power Hardware Management Console (HMC) V11R1 or later
- Managed systems: IBM Power10 or IBM Power11

## Installation

```hcl
terraform {
  required_providers {
    powerhmc = {
      source  = "ibm/powerhmc"
      version = "1.0.0"
    }
  }
}
```

## Provider Configuration

```hcl
provider "powerhmc" {
  host     = "hmc.example.com"
  username = "hscroot"
  password = var.hmc_password
}
```

Credentials can also be set via environment variables: `POWERHMC_HOST`, `POWERHMC_USERNAME`, `POWERHMC_PASSWORD`.

## Capabilities

| Type | Name | Description |
|------|------|-------------|
| Resource | `powerhmc_lpar` | Create and manage Logical Partitions (LPARs). Immutable — changes force replace. |
| Resource | `powerhmc_vios` | Create and manage Virtual I/O Server (VIOS) partitions. Immutable — changes force replace. |
| Resource | `powerhmc_sys_config` | Configure an existing managed system (CEC). Import required before first apply. |
| Data source | `powerhmc_lpar` | Look up an existing LPAR by name. |
| Data source | `powerhmc_vios` | Look up an existing VIOS partition by name. |
| Data source | `powerhmc_sys_config` | Read the current configuration and state of a managed system. |
| Action | `powerhmc_partition_power_on_off` | Power an LPAR or VIOS on or off. Supports AIX/Linux, IBM i, and VIOS types. |
| Action | `powerhmc_sys_on_off` | Power a whole managed system (CEC) on or off. |
| Action | `powerhmc_lpar_netboot` | Power on an LPAR and boot it from a network server. |
| Action | `powerhmc_vios_install` | Install VIOS onto a partition from an image staged on the HMC. |

## Quick Examples

**Create an LPAR:**

```hcl
resource "powerhmc_lpar" "app" {
  system_name    = "Server-9009-22A-SN123456"
  lpar_name      = "app01"
  partition_type = "AIX/Linux"  # "AIX/Linux" | "ibmi"

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
}
```

**Power a partition on:**

```hcl
action "powerhmc_partition_power_on_off" "on" {
  config {
    system_name    = "Server-9009-22A-SN123456"
    partition_name = "app01"
    partition_type = "lpar"   # "lpar" | "vios"
    action         = "poweron"
  }
}
```

**Install VIOS:**

```hcl
action "powerhmc_vios_install" "install" {
  config {
    system_name       = "Server-9009-22A-SN123456"
    vios_name         = "vios1"
    profile_name      = "default_profile"
    installation_type = "image"
    image_source      = "installation_image"
    ip_address        = "10.0.0.60"
    subnet_mask       = "255.255.255.0"
    gateway           = "10.0.0.1"
    boot_device       = "U78AE.001.WZS0225-P1-C18-L1-T1"
    license_accept    = true
  }
}
```

For full attribute reference and additional examples, see the provider documentation.
