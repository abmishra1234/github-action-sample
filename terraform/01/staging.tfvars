# Staging values. Use -var-file=staging.tfvars.

# Greeting file
greeting        = "Hello from the staging environment!"
filename        = "staging_greeting.txt"
file_permission = "0644"

# Application configuration (demonstration credentials only)
app_username    = "staging-user"
app_password    = "staging-example-password"
app_replicas    = 2
app_environment = "staging"

# Feature flags
feature = {
  metrics = true
}
