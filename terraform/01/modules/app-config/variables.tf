# Child-module inputs receive values from arguments in the parent's module block.
variable "app_name" {
  type        = string
  description = "Application name used in the generated configuration and filename"
}

variable "environment" {
  type        = string
  description = "Environment used in the generated configuration and filename"
}

variable "output_dir" {
  type        = string
  description = "Directory where the caller wants configuration files generated"
}

variable "port" {
  type        = number
  description = "Application listening port"
  default     = 8080
}

variable "extra_settings" {
  type        = map(string)
  description = "Additional application-specific settings"
  default     = {}
}
