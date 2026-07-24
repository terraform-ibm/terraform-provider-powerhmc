---
page_title: "Authentication"
subcategory: "Guides"
description: |-
  How the IBM Power Systems HMC provider authenticates to a Hardware Management Console, and the credential chain it resolves.
---

# Authentication

The provider authenticates to the **Hardware Management Console (HMC)** with a
username and password and communicates over **HTTPS**.

## The credential chain

The provider resolves connection settings from an ordered chain, so you can keep
secrets out of your configuration and state files. Three sources are consulted,
in order of precedence (highest first):

1. **Static configuration** — values set directly in the `provider` block.
2. **Environment variables** — `POWERHMC_*`.
3. **Credentials file** — a named profile in `~/.ibmp/credentials`.

How each setting is resolved depends on whether it is a credential or a
connection setting:

* `username` and `password` are resolved **together, as a set**: the first
  source in the chain that supplies *both* a username and a password wins, and
  no lower source is consulted for either value.
* `host`, `insecure`, `profile`, and `credentials_file` are resolved
  **independently, field by field**, using the same precedence order — so you
  can, for example, set `host` in the environment while credentials come from a
  file profile.

| Setting | Provider block | Environment variable | Credentials-file profile | Default |
|---|---|---|---|---|
| `host` | `host` | `POWERHMC_HOST` | `host` | — (required) |
| `username` | `username` | `POWERHMC_USERNAME` | `username` | — (required) |
| `password` | `password` | `POWERHMC_PASSWORD` | `password` | — (required) |
| `insecure` | `insecure` | `POWERHMC_INSECURE` | `insecure` | `false` (verify TLS) |
| `profile` | `profile` | `POWERHMC_PROFILE` | — | `default` |
| `credentials_file` | `credentials_file` | `POWERHMC_CREDENTIALS_FILE` | — | `~/.ibmp/credentials` |

The three rungs below show how to authenticate with each source on its own.

## Rung 1 — Static configuration (highest precedence)

Set credentials directly in the `provider` block. This is the most explicit
option; keep the password in a sensitive variable rather than a literal so it
never lands in source control.

```terraform
provider "powerhmc" {
  host     = "hmc.example.com" # hostname or IP address
  username = "hscroot"
  password = var.hmc_password
}

variable "hmc_password" {
  type      = string
  sensitive = true
}
```

~> **Never commit credentials.** Use a sensitive variable, an environment
variable, or a credentials-file profile. The `password` attribute is marked
sensitive and is redacted from Terraform plan and apply output, but a literal in
source control is still exposed.

## Rung 2 — Environment variables (recommended)

Leave the `provider` block empty and export the `POWERHMC_*` variables. This
keeps secrets out of your configuration and state files, and is the recommended
approach for CI and shared automation:

| Setting | Environment variable |
|---|---|
| `host` | `POWERHMC_HOST` |
| `username` | `POWERHMC_USERNAME` |
| `password` | `POWERHMC_PASSWORD` |
| `insecure` | `POWERHMC_INSECURE` |
| `profile` | `POWERHMC_PROFILE` |
| `credentials_file` | `POWERHMC_CREDENTIALS_FILE` |

```shell
export POWERHMC_HOST="hmc.example.com"
export POWERHMC_USERNAME="hscroot"
export POWERHMC_PASSWORD="…"
```

```terraform
provider "powerhmc" {}
```

`POWERHMC_INSECURE` accepts `true`, `1`, or `yes` (case-insensitive) to disable
TLS verification; any other value keeps verification enabled.

## Rung 3 — Credentials file and profiles

A credentials file lets you keep several HMC connection targets on disk and
select one by name — with no secrets in your Terraform configuration at all. The
file is YAML with one or more named profiles:

```yaml
profiles:
  default:
    host: hmc1.example.com
    username: hscroot
    password: changeme
  prod:
    host: hmc-prod.example.com
    username: admin
    password: changeme
    # insecure: true   # optional; skip TLS verification for this profile
```

Each profile is a complete connection target (`host`, `username`, `password`,
and an optional `insecure` flag). Select one with the `profile` argument (or
`POWERHMC_PROFILE`); the default is the profile named `default`:

```terraform
provider "powerhmc" {
  profile = "prod"
}
```

The file path defaults to `~/.ibmp/credentials` and can be overridden with the
`credentials_file` argument or `POWERHMC_CREDENTIALS_FILE`:

```terraform
provider "powerhmc" {
  credentials_file = "/etc/ibmp/credentials"
  profile          = "prod"
}
```

-> Restrict the file to owner-only access with `chmod 0600 ~/.ibmp/credentials`.
The provider emits a warning when the file is readable or writable by group or
others.

### Mixing sources

Because non-credential fields resolve independently, you can combine rungs. For
example, keep the username and password in a file profile while overriding just
the host from the environment for a one-off run:

```shell
export POWERHMC_HOST="hmc-staging.example.com"
```

```terraform
provider "powerhmc" {
  profile = "prod" # username/password come from the "prod" profile
  # host is taken from POWERHMC_HOST above, overriding the profile's host
}
```

## The `profile` attribute

The `profile` attribute tells the provider which named entry in the credentials
file to use. It resolves through the same precedence chain as every other
non-credential setting:

1. `profile` in the `provider` block.
2. The `POWERHMC_PROFILE` environment variable.
3. Literal `default` — the profile named `default` in the credentials file.

Note that `profile` itself cannot appear inside a credentials-file profile (it
is a selector, not a credential), so it has no row in the profiles themselves.

### Setting the profile in the provider block

```terraform
provider "powerhmc" {
  profile = "prod"
}
```

### Setting the profile via an environment variable

```shell
export POWERHMC_PROFILE="prod"
```

```terraform
provider "powerhmc" {}
```

### Using the implicit `default` profile

When neither the provider block nor the environment variable is set, the
provider reads the profile named `default`. This is the most common case and
requires no explicit configuration:

```yaml
# ~/.ibmp/credentials
profiles:
  default:
    host: hmc.example.com
    username: hscroot
    password: changeme
```

```terraform
provider "powerhmc" {}   # reads the "default" profile automatically
```

### Selecting a non-default profile

Add as many named profiles as you need — one per HMC or environment — then
choose among them at plan time without touching the Terraform configuration:

```yaml
# ~/.ibmp/credentials
profiles:
  default:
    host: hmc-dev.example.com
    username: hscroot
    password: changeme
  staging:
    host: hmc-staging.example.com
    username: hscroot
    password: changeme
  prod:
    host: hmc-prod.example.com
    username: admin
    password: changeme
    insecure: false
```

```shell
# Use the "staging" profile for this run only
export POWERHMC_PROFILE="staging"
terraform plan
```

-> Profile names are **case-sensitive** and must match the YAML key exactly.
If the named profile is absent from the file, the provider reports a
`Missing PowerHMC Credentials` error that lists the file path and the profile
name it was looking for.

## The `host` value

`host` is the HMC's hostname or IP address — for example `hmc.example.com` or
`9.114.194.23`. Do not include a scheme or path; the provider always connects
over HTTPS. An explicit port is allowed (for example `hmc.example.com:12443`).

## Managing multiple HMCs

To manage more than one HMC from a single configuration, declare an aliased
`provider` block per HMC and select it with `provider =` on each resource, data
source, or action:

```terraform
provider "powerhmc" {
  alias    = "site_a"
  host     = "hmc-a.example.com"
  username = "hscroot"
  password = var.hmc_a_password
}

provider "powerhmc" {
  alias    = "site_b"
  host     = "hmc-b.example.com"
  username = "hscroot"
  password = var.hmc_b_password
}

resource "powerhmc_lpar" "app_a" {
  provider    = powerhmc.site_a
  system_name = "Server-A-9009-22A-SN000001"
  lpar_name   = "app-a"
  # ...
}

resource "powerhmc_lpar" "app_b" {
  provider    = powerhmc.site_b
  system_name = "Server-B-9009-22A-SN000002"
  lpar_name   = "app-b"
  # ...
}
```

Aliased providers pair well with credentials-file profiles: give each alias a
`profile` instead of inline credentials to keep all secrets on disk.

## HMC users and roles

Authenticate with an HMC user (such as the built-in `hscroot`, or a dedicated
automation user) that has permission to view and manage the managed systems,
VIOS partitions, and LPARs you intend to work with. A least-privilege automation
user scoped to the relevant managed systems is recommended for production use.

## TLS and self-signed certificates

The provider connects to the HMC over HTTPS and **verifies the certificate by
default**. For production use, install a trusted certificate on the HMC.

Many HMCs present a self-signed certificate. To connect to one without a trusted
certificate, disable verification by setting `insecure = true` in the provider
block (or `POWERHMC_INSECURE=true`, or `insecure: true` on the selected
credentials-file profile). The provider emits a warning whenever verification is
disabled; limit this to trusted networks. Validate connectivity with the
[`powerhmc_sys_config` data source](../data-sources/sys_config.md)
before provisioning resources.

## Verifying connectivity

The quickest way to confirm your credentials work is a read-only plan against a
data source:

```terraform
data "powerhmc_sys_config" "check" {
  name = "Server-9009-22A-SN123456"
}
```

```shell
terraform plan
```

A successful plan that resolves the system's computed attributes confirms the
host, credentials, and network path are all working. Authentication failures
surface as an explicit `Authentication Failed` diagnostic instructing you to
check the username and password. When no credentials can be resolved at all, the
provider reports a `Missing PowerHMC Credentials` error that lists every source
it tried.
