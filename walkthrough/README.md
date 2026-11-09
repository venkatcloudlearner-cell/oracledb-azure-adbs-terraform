# Staged walkthrough

These cumulative snapshots reproduce the blog sequence. Copy their source files
into one fresh working directory, in order, keeping the same Terraform state.
Do not run apply inside these reference folders. Do not copy an earlier stage
over a working directory that already manages later-stage resources.

| Stage | Adds | Expected new resources |
| --- | --- | --- |
| 01-resource-group | Resource group | 1 |
| 02-vnet | VNet | 1 |
| 03-delegated-subnet | Oracle subnet | 1 |
| 04-database | Private database and AzAPI provider | 1 |
| 05-client | Linux VM and networking | 6 |

Copy terraform.tfvars.example from the repository root to the working directory
as terraform.tfvars and customize it. All snapshots declare its input names;
the database password is required only from stage 04 onwards. Copy the password
helper at stage 04. Set TF_VAR_client_ssh_source_cidr and create the public SSH
key before planning stage 05. Run init at stages 01 and 04, validate and review a
fresh plan at every stage, and apply only the intended plan.

Snapshots are source examples, not verified deployments of their own. Their
configuration is derived from the original lab; no cloud resources are created
by validating these files. The original lab applied the resources in this order.
