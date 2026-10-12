output "hello_world_content" {
  value = local_file.hello_world.content
}

output "hello_world_filename" {
  value = local_file.hello_world.filename
}
