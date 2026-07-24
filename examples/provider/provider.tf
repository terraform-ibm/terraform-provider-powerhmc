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
