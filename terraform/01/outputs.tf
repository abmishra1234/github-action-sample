output "hello_world_content" {
  value = local_file.hello_world.content
}

output "hello_world_filename" {
  value = local_file.hello_world.filename
}

# Outputs from the single greeting module instance
output "greeting_app_config_file" {
  description = "Path of the greeting module configuration file"
  value       = module.greeting.app_config_file
}

output "greeting_app_config_content" {
  description = "Contents of the greeting module configuration file"
  value       = module.greeting.app_config_content
}

output "greeting_local_settings" {
  description = "Settings computed inside the greeting module"
  value       = module.greeting.local_settings
}

# Billing uses for_each, so expose a map keyed by test and prod
output "billing_app_config_files" {
  description = "Billing configuration paths keyed by environment"
  value       = { for environment, app in module.billing : environment => app.app_config_file }
}

output "billing_app_config_contents" {
  description = "Billing configuration contents keyed by environment"
  value       = { for environment, app in module.billing : environment => app.app_config_content }
}

output "billing_local_settings" {
  description = "Billing module settings keyed by environment"
  value       = { for environment, app in module.billing : environment => app.local_settings }
}

