# Greeting file inputs
variable "greeting" {
  type        = string
  description = "Text written to the local greeting file"
  default     = "Hello students of Terraform class , Python batch 26!"

  validation {
    condition     = length(trimspace(var.greeting)) > 0
    error_message = "Greeting must contain at least one non-whitespace character."
  }
}

variable "filename" {
  type        = string
  description = "Name of the .txt file created in the exercise directory"
  default     = "hello_world.txt"

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]+\\.txt$", var.filename))
    error_message = "Filename must end in .txt and contain only letters, numbers, underscores, or hyphens before the extension."
  }
}

variable "file_permission" {
  type        = string
  description = "File permissions as a four-digit octal string"
  default     = "0644"

  validation {
    condition     = can(regex("^0[0-7]{3}$", var.file_permission))
    error_message = "File permission must be a four-digit octal string such as 0644 or 0600."
  }
}
# Protected file input
variable "database_username" {
  type        = string
  description = "Database username written to the file protected from destruction"
  default     = "example-user"
}

# Application configuration inputs
variable "app_username" {
  type        = string
  description = "Username written to the application configuration file"
}

variable "app_password" {
  type        = string
  description = "Password written to the application configuration file"
  sensitive   = true
}

variable "app_replicas" {
  type        = number
  description = "Replica count written to the application configuration file"
}

variable "app_environment" {
  type        = string
  description = "Environment written to the application configuration file"
}

# Feature flags
variable "feature" {
  type = object({
    metrics = bool
  })
  description = "Application feature flags; metrics is required"
}

# Inputs passed from this root module to modules/app-config
variable "greeting_port" {
  type        = number
  description = "Port passed to the greeting module's port input"
  default     = 8080
}

variable "billing_ports" {
  type        = map(number)
  description = "Billing environments and ports used to create module instances"
  default = {
    test = 8101
    prod = 8102
  }
}

variable "billing_extra_settings" {
  type        = map(string)
  description = "Settings passed to each billing module's extra_settings input"
  default = {
    billing_currency = "USD"
  }
}

# Service definitions
variable "services" {
  description = "List of services"
  type = list(object({
    name   = string
    port   = string
    public = bool
  }))

  default = [
    {
      name   = "service1"
      port   = "8080"
      public = true
    },
    {
      name   = "service2"
      port   = "9090"
      public = false
    },
    {
      name   = "service3"
      port   = "7070"
      public = true
    }
  ]
}

