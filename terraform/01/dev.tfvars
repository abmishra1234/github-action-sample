# Development values. Use -var-file=dev.tfvars.

# Greeting file
greeting        = "Hello from the development environment!"
filename        = "dev_greeting.txt"
file_permission = "0644"

# Application configuration (demonstration credentials only)
app_username    = "dev-user"
app_password    = "dev-example-password"
app_replicas    = 1
app_environment = "dev"

# Feature flags
feature = {
  metrics = false
}
