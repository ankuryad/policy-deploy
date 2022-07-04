variable "disallow_internet_parameters" {
  default = <<PARAMETERS
{
  "effect": {
    "value": "Deny
  }
}
PARAMETERS
}