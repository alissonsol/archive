resource "null_resource" "registry" {
  provisioner "local-exec" {
    command = "./localhost-registry.ps1"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["pwsh", "-Command"]

    environment = {
    }
  }
}

data "external" "registryLocation" {
  program = [
    "pwsh",
    "./registry-location.ps1",
    "dummy",
  ]

  query = {
    dummy = "dummy" 
  }
}

output "registryLocation" {
  value = data.external.registryLocation.result.registryLocation
}
