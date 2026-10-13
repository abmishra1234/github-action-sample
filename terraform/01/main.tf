
locals {
  prefix              = "${lower(var.app_environment)}-app"
  log_level           = var.app_environment == "production" ? "info" : "debug"
  service_names       = [for service in var.services : upper(service.name)]
  public_services     = [for service in var.services : upper(service.name) if service.public]
  service_ports       = [for service in var.services : service.port]
  service_ports_splat = var.services[*].port
  service_ports_map   = { for service in var.services : service.name => service.port }
  summary = {
    count        = length(var.services)
    public_count = length(local.public_services)
    highest_port = max([for port in local.service_ports_splat : tonumber(port)]...)
    merged_tags  = merge({ env = local.prefix }, { managed_by = "terraform" })
    has_billing  = contains(keys(var.feature), "billing")
  }

}

// template for generating configuration files
resource "local_file" "nginx_template" {
  filename = "${path.module}/output/nginx.conf"
  content = templatefile("${path.module}/templates/nginx.conf.tpl", {
    service_names     = local.service_names
    public_services   = local.public_services
    service_ports_map = local.service_ports_map
    log_level         = local.log_level
  })
}

resource "local_file" "file1" {
  count    = var.app_replicas
  filename = "${path.module}/output/file1_${count.index}.txt"
  content  = "This is file1 content"
}

// Using for_each
resource "local_file" "file1_foreach" {
  for_each = toset(local.service_names)
  filename = "${path.module}/output/file1_${each.value}.txt"
  content  = "This is file1 content for replica ${each.value}"
}

resource "local_file" "example" {
  content         = var.database_username
  filename        = "${path.module}/hello.txt"
  file_permission = "0644"

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_password" "database_password" {
  length  = 16
  special = true
}

resource "local_file" "hello_world" {
  content         = var.greeting
  filename        = var.filename
  file_permission = var.file_permission
}

resource "local_file" "summary_json" {
  content  = jsonencode(local.summary)
  filename = "${path.module}/output/summary.json"
}

resource "local_file" "app_configuration" {
  filename = "${path.module}/output/app_configuration.txt"
  content  = <<EOT
  {
    app.username = ${var.app_username}
    app.password = ${var.app_password}
    app.replicas = ${var.app_replicas}
    app.environment = ${local.prefix}
    feature.metrics = ${var.feature["metrics"]}
  }
  EOT
}

module "greeting" {
  source      = "./modules/app-config"
  app_name    = "greeting"
  environment = var.app_environment
  port        = var.greeting_port
  output_dir  = "${path.module}/output"
}

module "billing" {
  source = "./modules/app-config"

  for_each = var.billing_ports

  app_name       = "billing"
  environment    = each.key
  port           = each.value
  output_dir     = "${path.module}/output"
  extra_settings = var.billing_extra_settings
}

resource "local_file" "always_present" {
  filename = "${path.module}/output/always_present.txt"
  content  = "This file is always present"

  lifecycle {
    create_before_destroy = true
  }
}





