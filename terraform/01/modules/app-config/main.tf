locals {
  settings = merge(
    {
      "app_name"    = var.app_name
      "environment" = var.environment
      "port"        = tostring(var.port)
      "output_dir"  = var.output_dir
    },
    var.extra_settings
  )
}

resource "local_file" "app_config" {
  filename = "${var.output_dir}/${var.app_name}-${var.environment}.json"
  content = jsonencode({
    app_name       = var.app_name
    environment    = var.environment
    port           = var.port
    extra_settings = var.extra_settings
  })
}
