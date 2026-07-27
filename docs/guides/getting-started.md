---
page_title: "Getting Started with the IBM Power Systems HMC Provider"
subcategory: "Guides"
description: |-
  Install the provider, authenticate to an HMC, and provision your first LPAR end to end.
---

# Getting Started

This guide takes you from an empty directory to a running Logical Partition
(LPAR) on IBM Power hardware in a few minutes. You will configure the provider,
import an existing managed system, and create an LPAR.

## Prerequisites

* [Terraform](https://developer.hashicorp.com/terraform/downloads) **v1.0 or later**.
  (Provider [actions](actions.md) require **Terraform v1.14 or later**.)
* Network access to a **Hardware Management Console (HMC)** over HTTPS.
* HMC credentials with permission to view and manage the target managed system
  (see the [Authentication guide](authentication.md)).
* At least one **managed system** already connected to the HMC.
* **HMC V11R1 or later** managing **IBM Power10 or Power11** servers.

## Step 1 — Configure the provider

Create `main.tf`:

```terraform
terraform {
  required_providers {
    powerhmc = {
      source = "terraform-ibm/powerhmc"
    }
  }
}

provider "powerhmc" {
  host     = "hmc.example.com"
  username = "hscroot"
  password = var.hmc_password
}

variable "hmc_password" {
  type      = string
  sensitive = true
}
```

Prefer to keep secrets out of your files? Set `POWERHMC_HOST`,
`POWERHMC_USERNAME`, and `POWERHMC_PASSWORD` instead and leave the provider
block empty. See [Authentication](authentication.md).

Initialize the working directory:

```shell
terraform init
```

## Step 2 — Inspect a managed system (optional but recommended)

Use the [`powerhmc_sys_config` data source](../data-sources/sys_config.md)
to confirm connectivity and read the current configuration of a managed system:

```terraform
data "powerhmc_sys_config" "server" {
  name = "Server-9009-22A-SN123456"
}

output "system_state" {
  value = data.powerhmc_sys_config.server.state
}
```

```shell
terraform plan
```

If the plan succeeds and shows the system state, your credentials and
connectivity are good.

## Step 3 — Create your first LPAR

Add a [`powerhmc_lpar` resource](../resources/lpar.md). This example
creates a small AIX/Linux partition with shared processors:

```terraform
resource "powerhmc_lpar" "first" {
  system_name    = "Server-9009-22A-SN123456"
  lpar_name      = "hello-lpar"
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
}
```

Apply it:

```shell
terraform apply
```

Terraform creates the partition on the managed system. When it finishes,
`terraform show` displays the computed attributes — the partition `state`,
`lpar_uuid`, and `reference_code`.

## Step 4 — Power it on

Resources describe *desired configuration*; imperative operations such as
powering a partition on or off are modeled as **[actions](actions.md)**. Wire a
power-on action to the LPAR's lifecycle:

```terraform
action "powerhmc_partition_power_on_off" "boot" {
  config {
    system_name    = powerhmc_lpar.first.system_name
    partition_name = powerhmc_lpar.first.lpar_name
    partition_type = "lpar"
    action         = "poweron"
  }
}

resource "terraform_data" "power" {
  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.powerhmc_partition_power_on_off.boot]
    }
  }
}
```

## Where to go next

* [Authentication](authentication.md) — HMC users, roles, and self-signed certificates.
* [Actions](actions.md) — power control, LPAR network boot, and VIOS installation.
* [`powerhmc_vios` resource](../resources/vios.md) — create Virtual I/O Server partitions.
* [`powerhmc_sys_config` resource](../resources/sys_config.md) — manage managed-system settings (import-only).

## Cleaning up

```shell
terraform destroy
```

This removes the LPAR from the managed system. Note that destroying a
`powerhmc_sys_config` resource only removes it from Terraform state — it never
powers off or deletes the physical managed system.
