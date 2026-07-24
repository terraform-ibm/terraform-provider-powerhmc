# Examples

This directory contains runnable Terraform examples for the IBM Power Systems
HMC provider. The examples under the paths below are wired into the generated
documentation by [`tfplugindocs`](https://github.com/hashicorp/terraform-plugin-docs);
each file is embedded verbatim into the corresponding Registry page.

## Documentation-linked examples

The documentation generator picks up these files by convention (the directory
name must be the **full** object name, including the `powerhmc_` prefix):

| Path | Rendered on |
|---|---|
| `provider/provider.tf` | Provider index page |
| `resources/<full resource name>/resource.tf` | That resource's page |
| `resources/<full resource name>/import.sh` | The resource's **Import** section |
| `data-sources/<full data source name>/data-source.tf` | That data source's page |
| `actions/<full action name>/action.tf` | That action's page |

Current documentation-linked examples:

```
provider/provider.tf

resources/powerhmc_lpar/{resource.tf,import.sh}
resources/powerhmc_vios/{resource.tf,import.sh}
resources/powerhmc_sys_config/{resource.tf,import.sh}

data-sources/powerhmc_lpar/data-source.tf
data-sources/powerhmc_vios/data-source.tf
data-sources/powerhmc_sys_config/data-source.tf

actions/powerhmc_lpar_netboot/action.tf
actions/powerhmc_partition_power_on_off/action.tf
actions/powerhmc_vios_install/action.tf
actions/powerhmc_sys_on_off/action.tf
```

## Running an example

```shell
cd resources/powerhmc_lpar
terraform init
terraform plan
```

Provide credentials through the `POWERHMC_HOST`, `POWERHMC_USERNAME`, and
`POWERHMC_PASSWORD` environment variables, a named profile in
`~/.ibmp/credentials`, or the `provider` block. See the
[Authentication guide](../docs/guides/authentication.md) for the full credential
resolution chain and profile setup.
