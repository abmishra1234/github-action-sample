output "filename" {
  description = "Path of the generated application configuration"
  value       = local_file.app_config.filename
}

output "app_config_file" {
  description = "The path to the generated application configuration file"
  value       = local_file.app_config.filename
}

output "app_config_content" {
  description = "The content of the generated application configuration file"
  value       = local_file.app_config.content
}

output "local_settings" {
  description = "All local settings used to generate the application configuration"
  value       = local.settings
}
