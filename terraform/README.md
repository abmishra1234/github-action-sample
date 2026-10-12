# Terraform learning exercises

This directory starts with a small local-file exercise so you can learn Terraform's configuration, providers, resources, outputs, and state before using a cloud provider. Exercise `01` writes a greeting to a file on the machine running Terraform. Its greeting, filename, and permissions are configurable through command-line inputs; you can leave `main.tf` and `dev.tfvars` unchanged. It does not require cloud credentials.

## Directory structure

```text
terraform/
|-- README.md
`-- 01/
    |-- main.tf                # Managed file resources
    |-- versions.tf            # Terraform and provider requirements
    |-- variables.tf           # Input declarations and validation
    |-- outputs.tf             # Values exposed by the module
    |-- dev.tfvars             # Complete development values
    |-- staging.tfvars        # Complete staging values
    |-- .terraform.lock.hcl
    |-- .terraform/            # Downloaded provider binaries; generated
    |-- terraform.tfstate     # Local state; generated
    `-- hello_world.txt       # File managed by the resource; generated
```

| File or directory | What to learn |
| --- | --- |
| [01/main.tf](01/main.tf) | Managed resources: the greeting file and application configuration file. |
| [01/versions.tf](01/versions.tf) | Terraform CLI version requirement and local provider dependency. |
| [01/variables.tf](01/variables.tf) | Input variable declarations, defaults, and validation rules. |
| [01/outputs.tf](01/outputs.tf) | Greeting content and filename outputs. |
| `01/.terraform.lock.hcl` | The selected provider version and integrity hashes. The existing lock selects `hashicorp/local` version `2.9.1`. |
| `01/.terraform/` | Local provider installation cache, recreated by initialization. The inspected installation contains a Windows AMD64 provider. |
| `01/terraform.tfstate` | Terraform's record of the objects it manages. The existing state records `local_file.hello_world` and Terraform `1.13.3`. |
| `01/hello_world.txt` | The file created with the default filename; content depends on the greeting used for the last apply. |

Run commands from `01/`. That directory is the root module for this exercise; running commands from `terraform/` would use a different configuration directory.

Terraform loads all `.tf` files in this directory together as one module. File
names organize the code; they do not define execution order. Continue running
the same commands from `01/` and overriding inputs with `-var` or `-var-file`.

## Read the configuration

### Terraform and provider requirements

```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}
```

`required_version` constrains the Terraform CLI. The provider's `version` constrains the plugin independently. `source` identifies the provider in the registry, while `local` is its name within this module. The version range is broad; the lock file records the specific installed selection. See [provider requirements](https://developer.hashicorp.com/terraform/language/providers/requirements).

### The managed resource

```hcl
resource "local_file" "hello_world" {
  content         = var.greeting
  filename        = var.filename
  file_permission = var.file_permission
}
```

`local_file` is the provider's resource type. `hello_world` is a Terraform label, not the disk filename. Together they form the resource address `local_file.hello_world`. The relative filename is resolved from the execution directory; the commands below run inside `01/`.

The provider creates the file and manages its contents. If the configured path already contains a file, applying this resource can overwrite it. See the [local_file resource reference](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file).

### Outputs

The two output blocks expose attributes of the managed resource:

| Output | Expression | Expected value after applying |
| --- | --- | --- |
| `hello_world_content` | `local_file.hello_world.content` | The greeting supplied to apply. |
| `hello_world_filename` | `local_file.hello_world.filename` | The filename supplied to apply, or `hello_world.txt` by default. |

These expressions reference the resource directly, rather than duplicating its values. Outputs can be read with `terraform output` after they have been recorded in state.

### File permissions

The resource already uses `file_permission = var.file_permission`, with a default
of `"0644"`. The provider accepts an octal string, not an owner/group/mode object.
On Unix-like systems, `0644` expresses owner read/write and group/other read
access. Windows uses a different permission model; this setting does not assign
Windows ownership or configure Windows ACLs. Consult the [provider's permission schema](https://raw.githubusercontent.com/hashicorp/terraform-provider-local/main/docs/resources/file.md).

## Run the exercise

Install Terraform and make sure it is available on `PATH`. The configuration requires version `1.0.0` or newer. Initial provider installation requires registry access.

From the repository root, in PowerShell:

```powershell
cd terraform/01
terraform version
terraform init
terraform fmt -check
terraform validate
terraform plan
```

| Command | Purpose |
| --- | --- |
| `init` | Initializes the working directory and installs the required provider. |
| `fmt -check` | Reports files that need Terraform's standard formatting without changing them. Use `terraform fmt` to format them. |
| `validate` | Checks whether the configuration is valid with the installed provider. It does not create the file. |
| `plan` | Previews how Terraform would reconcile configuration, state, and the actual file. |
| `apply` | Executes changes after you review and confirm the proposed plan. |
| `output` | Displays outputs saved in state. |
| `destroy` | Proposes removal of managed resources and removes them after confirmation. |

This follows Terraform's [write, plan, and apply workflow](https://developer.hashicorp.com/terraform/cli/run). Formatting is a separate check from validity.

Review the plan, then apply:

```powershell
terraform apply
# Enter yes when you accept the proposed changes.
Get-Content ./hello_world.txt
terraform output
terraform output -raw hello_world_content
```

With no overrides, the file should contain the default greeting listed below. On a fresh exercise, the plan should propose one resource to create. This checkout already contains state and the generated file, so an unchanged exercise can instead report no changes. Exact changes depend on your current configuration and filesystem. For custom values, follow the command-line workflow below instead of a plain apply.

To practice saving and inspecting a plan:

```powershell
terraform plan '-out=learning.tfplan'
terraform show learning.tfplan
terraform apply learning.tfplan
```

Applying a saved plan executes the previously reviewed actions without another approval prompt. See the [plan command reference](https://developer.hashicorp.com/terraform/cli/commands/plan).

## Inspect state and repeat

```powershell
terraform state list
terraform state show local_file.hello_world
terraform plan
```

The state list should include `local_file.hello_world`. A second plan after a successful apply, with no other changes, demonstrates convergence: the actual file already matches the declared configuration.

State and the dependency lock file serve different purposes: state tracks managed objects; the lock file tracks selected provider dependencies. Keep `.terraform.lock.hcl` in version control for a shared exercise. Avoid committing downloaded `.terraform/` directories, state files, saved plans, or generated files. State and plan files may contain resource data. See [dependency lock file guidance](https://developer.hashicorp.com/terraform/language/files/dependency-lock).

The root `.gitignore` currently does not exclude Terraform artifacts. If you decide to commit these exercises, useful Terraform-specific ignore patterns are:

```gitignore
# Patterns for a .gitignore placed inside terraform/
**/.terraform/
*.tfstate
*.tfstate.*
*.tfplan
.terraform.tfstate.lock.info
01/hello_world.txt
```

These are suggested patterns; this documentation task did not change ignore rules.

## Environment variable files

Keep declarations, types, defaults, and validation in `variables.tf`. The `.tfvars`
files contain assignments only, while resources in `main.tf` are shared across
environments. Each example file supplies all eight declared inputs.

| Input | `dev.tfvars` | `staging.tfvars` |
| --- | --- | --- |
| `greeting` | Development greeting | Staging greeting |
| `filename` | `dev_greeting.txt` | `staging_greeting.txt` |
| `file_permission` | `"0644"` | `"0644"` |
| `app_username` | `dev-user` | `staging-user` |
| `app_password` | Demonstration value | Demonstration value |
| `app_replicas` | `1` | `2` |
| `app_environment` | `dev` | `staging` |
| `feature.metrics` | `false` | `true` |

The staging file uses `staging` as its environment value. Both files are loaded
explicitly, not automatically.

From `terraform/01`, initialize and validate once:

```powershell
terraform init
terraform validate
```

Preview and apply development values without editing the configuration:

```powershell
terraform plan '-var-file=dev.tfvars' '-out=dev.tfplan'
terraform show dev.tfplan
terraform apply dev.tfplan
Get-Content ./dev_greeting.txt
terraform output
terraform plan '-var-file=dev.tfvars'
```

Preview and apply staging values:

```powershell
terraform plan '-var-file=staging.tfvars' '-out=staging.tfplan'
terraform show staging.tfplan
terraform apply staging.tfplan
Get-Content ./staging_greeting.txt
terraform output
terraform plan '-var-file=staging.tfvars'
```

Saved plans include the selected values. Review them before applying: applying
a saved plan does not prompt for confirmation. The final plan with the same
inputs should report no changes after a successful apply.

These examples use the **same state**. Selecting another `.tfvars` file switches
the configuration of the managed resources; it does not create an independent
environment. Switching can replace the greeting file and rewrites the shared
`output/app_configuration.txt`. Use separate state and output paths if you later
need both environments to coexist.

Override one value without editing either file by placing `-var` after `-var-file`:

```powershell
terraform plan '-var-file=dev.tfvars' '-var=app_replicas=3'
terraform apply '-var-file=dev.tfvars' '-var=app_replicas=3'
```

Repeat the override in later plans to keep the same desired configuration.
Passwords are demonstration values; the existing resource writes the password
into the local file and state even though the input is marked sensitive.

## Extended variable example

`01/variables.tf` defines three greeting-file string inputs:

| Input | Default | Validation |
| --- | --- | --- |
| `greeting` | `Hello students of Terraform class , Python batch 26!` | Must not be empty or whitespace-only. |
| `filename` | `hello_world.txt` | A `.txt` filename using letters, numbers, underscores, and hyphens; paths are not accepted. |
| `file_permission` | `0644` | A four-character octal string starting with `0`, such as `0644` or `0600`. |

The resource refers to `var.greeting`, `var.filename`, and `var.file_permission`.
The existing outputs still read the resource's resulting values. Permissions
remain a string: write `"0644"`, rather than a numeric value.

The application configuration resource also requires `app_username` (string),
`app_password` (sensitive string), `app_replicas` (number), `app_environment`
(string), and `feature` (an object with a Boolean `metrics` attribute). These
inputs have no defaults. Before using the plan/apply examples below, supply them
through the current PowerShell session:

```powershell
$env:TF_VAR_app_username = 'classroom-user'
$env:TF_VAR_app_password = 'example-only-password'
$env:TF_VAR_app_replicas = '2'
$env:TF_VAR_app_environment = 'dev'
$env:TF_VAR_feature = '{"metrics":true}'
```

This supplies example values without editing files. The password is marked
sensitive for CLI display, but the existing resource writes it into the local
configuration file and state. Use demonstration values for this exercise.
Terraform prompts for any required inputs that you have not supplied.

### Change values using commands only

Run all commands below from `terraform/01`. Variable defaults are fallbacks;
`-var` supplies values for that invocation without rewriting configuration files.
`plan` previews the change. `apply` updates the managed file and state.

**1. Preview a greeting change without editing any file:**

```powershell
terraform plan '-var=greeting=Hello from the command line!'
```

Only `greeting` is overridden; `filename` and `file_permission` use their defaults.
For this resource, a content change forces replacement: typically the plan shows
`1 to add, 0 to change, 1 to destroy` for an existing file.

**2. Supply all three values and save the plan:**

```powershell
terraform plan '-var=greeting=Hello from the command line!' '-var=filename=command_greeting.txt' '-var=file_permission=0644' '-out=variables.tfplan'
terraform show variables.tfplan
```

Each complete argument is quoted for PowerShell, including values with spaces.
The permission argument supplies the string `0644`. The preview may propose
replacement for both the greeting and filename changes.

**3. Apply exactly the values you reviewed:**

```powershell
terraform apply variables.tfplan
```

The saved plan includes the input values, so do not add `-var` arguments to this
apply command. Applying a saved plan does not prompt again for confirmation.

**4. Inspect the resulting file and outputs:**

```powershell
Get-Content ./command_greeting.txt
terraform output
terraform output -raw hello_world_content
```

The file should contain `Hello from the command line!`, and the filename output
should be `command_greeting.txt`.

**5. Check convergence with the same values:**

```powershell
terraform plan '-var=greeting=Hello from the command line!' '-var=filename=command_greeting.txt' '-var=file_permission=0644'
```

After a successful apply, this should report **No changes** if nothing else has
changed. Overrides do not become new defaults: a plain `terraform plan` uses the
defaults again and can propose changing the file back. Repeat your overrides for
later plans and applies, or save a new plan each time.

If you prefer an interactive apply instead of a saved plan, pass the same values
directly and review the proposed changes before entering `yes`:

```powershell
terraform apply '-var=greeting=Hello from the command line!' '-var=filename=command_greeting.txt' '-var=file_permission=0644'
```

### Reuse arguments in the current PowerShell session

Store the arguments in a shell array to avoid typing them repeatedly. This does
not edit Terraform configuration or variable files:

```powershell
$terraformInputs = @(
  '-var=greeting=Hello from the command line!'
  '-var=filename=command_greeting.txt'
  '-var=file_permission=0644'
)
terraform plan @terraformInputs
terraform apply @terraformInputs
terraform plan @terraformInputs
```

`@terraformInputs` passes each array item as a separate command-line argument.

### Use the existing variable file without editing it

The existing example file can also be supplied as-is:

```powershell
terraform plan
terraform plan '-var-file=dev.tfvars'
```

`dev.tfvars` supplies all eight inputs together. Its filename is deliberately
not `terraform.tfvars` or `*.auto.tfvars`, so Terraform loads it only when you
explicitly supply `-var-file`. It proposes a different greeting and filename;
review the replacement before applying:

```powershell
terraform apply '-var-file=dev.tfvars'
Get-Content ./dev_greeting.txt
terraform output
```

Keep passing the same file when checking the resulting configuration. A later
plain `terraform plan` uses defaults again and may propose changing it back.

Override one value on the command line, or try a rejected value:

```powershell
terraform plan '-var-file=dev.tfvars' '-var=greeting=Hello from the command line!'
terraform plan '-var=file_permission=0999'
```

The first command demonstrates a later command-line value overriding the file's
greeting. The second should fail with the custom permission validation message,
without applying changes. Another option is a `TF_VAR_greeting` environment
variable; explicit variable-file and command-line values take precedence over
environment values. See [HashiCorp's input variable guide](https://developer.hashicorp.com/terraform/language/values/variables).

## Practice tasks

1. Override only `greeting` using `-var`. Predict the plan, review it, apply with the same argument, and inspect the output.
2. Override `filename` using `-var=filename=greeting.txt` together with your greeting. Observe replacement and inspect the new file.
3. Preview `-var=file_permission=0600` without changing the configuration. Unix-like systems can demonstrate the resulting permission difference.
4. Try `-var=file_permission=0999` and observe the custom validation error.
5. Load `dev.tfvars`, then override its greeting with a later `-var` argument. Observe which value appears in the plan.
6. After applying custom values, compare a plan using the same inputs with a plain plan using defaults. Review the difference before applying anything.

Each numbered directory can later become a separate exercise with its own configuration, initialization, and state. Variables, multiple resources, and modules are useful next topics after mastering this file example.

## Clean up

From `01/`, review the proposed removal and confirm if you want to delete the Terraform-managed file:

```powershell
terraform destroy
terraform state list
```

Destroy removes managed resources; it does not remove source configuration, the provider cache, or the lock file. Preserve state while resources are still managed rather than deleting it as a substitute for cleanup.

## Troubleshooting and inspection results

| Symptom | Next step |
| --- | --- |
| `terraform` is not recognized | Install Terraform, verify `PATH`, and open a new terminal. |
| Provider initialization or download fails | Check registry access and run `init` from `01/`. Let Terraform install the provider for your own OS. |
| Provider fails to respond during validation | Check provider logs, execution restrictions, and whether the binary matches your OS. A downloaded binary's presence does not prove it can start. |
| `fmt -check` reports `main.tf` | Run `terraform fmt` and review its formatting changes. |
| `fmt -diff` cannot find `diff` on Windows | Use `terraform fmt -check` without `-diff`, or inspect formatting changes with Git. |
| No resource creation appears in a plan | Inspect existing state and the generated file; the desired resource may already exist. |
| Permissions do not change | Check the resource-level string setting and the operating system's permission model. |

During this scan, Terraform `1.13.3` successfully validated the current configuration when the local provider could run outside the restricted execution environment. The initial restricted validation failed while retrieving its schema. This illustrates that configuration validity and effective permission settings are separate questions. No `apply` or `destroy` was run for this documentation task.
