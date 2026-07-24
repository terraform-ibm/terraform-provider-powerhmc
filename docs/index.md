---
page_title: "IBM Terraform Provider for Power Hardware Management Console"
description: |-
  Manage IBM Power Systems infrastructure — managed systems, VIOS partitions, and LPARs — declaratively through a Hardware Management Console (HMC).
---

# IBM Terraform Provider for Power Hardware Management Console

The **IBM Terraform Provider for Power Hardware Management Console** brings IBM Power infrastructure into your
Terraform workflows. It talks to a **Hardware Management Console (HMC)** over its
REST API so you can provision and operate managed systems, Virtual I/O Server
(VIOS) partitions, and Logical Partitions (LPARs) with the same declarative,
versioned, repeatable workflow you use for the rest of your infrastructure.

## Authorized Use Restriction

This program may be used only in conjunction with a validly licensed and paid entitlement for commercial IBM Terraform Self-Managed or IBM Terraform (SaaS) offering (or as later renamed). Use of this program with any other Terraform distribution, product, edition, or service, including Community Terraform, is not authorized under this Agreement.

## What you can manage

| Capability | Terraform objects |
|---|---|
| **Managed system (CEC) configuration** | [`powerhmc_sys_config`](resources/sys_config.md) resource · [`powerhmc_sys_config`](data-sources/sys_config.md) data source |
| **Virtual I/O Server (VIOS) partitions** | [`powerhmc_vios`](resources/vios.md) resource · [`powerhmc_vios`](data-sources/vios.md) data source |
| **Logical Partitions (LPARs)** | [`powerhmc_lpar`](resources/lpar.md) resource · [`powerhmc_lpar`](data-sources/lpar.md) data source |
| **Lifecycle operations** (power on/off, network boot, VIOS install) | [Actions](guides/actions.md): `powerhmc_sys_on_off`, `powerhmc_partition_power_on_off`, `powerhmc_lpar_netboot`, `powerhmc_vios_install` |

New to the provider? Start with the [Getting Started guide](guides/getting-started.md).

## Example Usage

```terraform
# Configure the IBM Power Systems HMC provider.
#
# Credentials are resolved from an ordered chain — the provider block, then the
# POWERHMC_* environment variables, then a named profile in the credentials
# file. Each block below shows one rung of that chain; see the Authentication
# guide for the full precedence rules.

terraform {
  required_providers {
    powerhmc = {
      source = "ibm.com/sys/powerhmc"
    }
  }
}

# Environment variables (recommended). With an empty block the provider reads
# POWERHMC_HOST, POWERHMC_USERNAME, and POWERHMC_PASSWORD, keeping secrets out
# of your configuration and state files.
provider "powerhmc" {}

# Static configuration. Values in the provider block take precedence over every
# other source. Keep the password in a sensitive variable, never a literal.
provider "powerhmc" {
  alias    = "static"
  host     = "hmc.example.com" # or an IP address, e.g. 9.114.194.23
  username = "hscroot"
  password = var.hmc_password
}

# Credentials-file profile. Reads the "prod" profile from ~/.ibmp/credentials,
# so no secrets appear in the configuration at all.
provider "powerhmc" {
  alias   = "prod_profile"
  profile = "prod"
}

# Credentials file in a non-default location. TLS certificates are verified by
# default; set insecure only for an HMC with a self-signed certificate.
provider "powerhmc" {
  alias            = "lab"
  credentials_file = "/etc/ibmp/credentials"
  profile          = "lab"
  insecure         = true
}

# Mixing sources. Non-credential fields resolve independently, so host can be
# overridden here while the username and password still come from the profile.
provider "powerhmc" {
  alias   = "staging"
  host    = "hmc-staging.example.com"
  profile = "prod"
}

variable "hmc_password" {
  type      = string
  sensitive = true
}
```

## Authentication

The provider authenticates to the HMC with a username and password and connects
over **HTTPS**. Credentials are resolved from an ordered chain of three sources,
highest precedence first — so you can keep secrets out of your configuration and
state files.

### 1. Static configuration

```terraform
provider "powerhmc" {
  host     = "hmc.example.com"
  username = "hscroot"
  password = var.hmc_password # use a sensitive variable, never a literal
}
```

### 2. Environment variables (recommended)

Keeping secrets out of your configuration is the recommended practice:

```shell
export POWERHMC_HOST="hmc.example.com"
export POWERHMC_USERNAME="hscroot"
export POWERHMC_PASSWORD="…"
```

```terraform
provider "powerhmc" {}
```

### 3. Credentials file profile

Store one or more named connection targets in `~/.ibmp/credentials` and select
one by name — no secrets in your Terraform configuration at all:

```terraform
provider "powerhmc" {
  profile = "prod"
}
```

`username` and `password` are resolved together as a set (the first source that
supplies both wins); `host` and `insecure` are resolved independently, field by
field. See the [Authentication guide](guides/authentication.md) for the full
credential chain, the credentials-file format, HMC user roles, and handling
self-signed HMC certificates.

<!-- schema generated by tfplugindocs -->
## Schema

### Optional

- `credentials_file` (String) Path to the PowerHMC credentials file. May also be set with the `POWERHMC_CREDENTIALS_FILE` environment variable. Defaults to `~/.ibmp/credentials`.
- `host` (String) Hostname or IP address of the HMC, without a scheme (for example `hmc1.example.com`). May also be set with the `POWERHMC_HOST` environment variable or the `host` field of the selected credentials-file profile. Resolution order: configuration > environment > credentials file.
- `insecure` (Boolean) Skip TLS certificate verification when connecting to the HMC. May also be set with the `POWERHMC_INSECURE` environment variable or the `insecure` field of the selected credentials-file profile. Resolution order: configuration > environment > credentials file. Defaults to `false` (certificates are verified). Set to `true` only for HMCs with self-signed certificates.
- `password` (String, Sensitive) HMC password. May also be set with the `POWERHMC_PASSWORD` environment variable or a credentials-file profile. Resolved together with `username`.
- `profile` (String) Name of the profile to read from the credentials file. May also be set with the `POWERHMC_PROFILE` environment variable. Defaults to `default`.
- `username` (String) HMC user name. May also be set with the `POWERHMC_USERNAME` environment variable or a credentials-file profile. Username and password are resolved together as a set, in the order: configuration > environment > credentials file.
