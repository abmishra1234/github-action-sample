# Look up an existing AWS VPC

This exercise uses the `aws_vpc` data source to read an existing VPC. It does not
create a VPC. `selected_vpc_id` returns its ID and `selected_vpc_arn` returns its
ARN; the screenshot used `.arn` under an ID output name, so these are exposed
separately here.

## Run on Windows PowerShell

Configure AWS credentials using your usual AWS CLI profile or AWS SSO setup.
Terraform uses the AWS provider's credential chain; do not put access keys in
Terraform source. For an existing named profile:

```powershell
$env:AWS_PROFILE = 'your-profile-name'
aws sts get-caller-identity
```

If that profile uses SSO, run `aws sso login --profile your-profile-name` first.
Your identity must be able to describe VPCs in the selected region.

From the repository root:

```powershell
cd terraform/02
terraform init
terraform validate
terraform plan '-var=aws_region=ap-south-1' '-var=vpc_id=vpc-YOUR-ACTUAL-ID' '-out=vpc-lookup.tfplan'
terraform apply vpc-lookup.tfplan
terraform output
```

Replace the example region and VPC ID with the region and ID from your account.
The screenshot's ID is the variable's default, not a guarantee that the VPC
exists in your account. `aws_region` is required; supplying it with `-var` avoids
an interactive prompt. Applying the saved plan records the lookup outputs in
local state and does not prompt again for confirmation.

If the lookup reports no matching VPC, verify the profile, region, and ID. If it
reports an authentication or access error, check your credential session and
permissions. The [AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
describes supported authentication methods.
