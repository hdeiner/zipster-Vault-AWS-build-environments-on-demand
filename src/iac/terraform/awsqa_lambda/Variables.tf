variable "environment" {
  description = "Unique name for the environment to be spun up"
  type = string
}

variable "VAULT_ADDRESS" {
  description = "DNS for Vault"
  type = string
  default = "DNS for Vault"
}

variable "VAULT_TOKEN" {
  description = "Vault token for access"
  type = string
  default = "Vault token for access"
}

variable "api_path" {
#  default = "{proxy+}"
  default = "zipster"
}

variable "lambda_payload_filename" {
  default = "../../../../target/zipster-1.0-SNAPSHOT.jar"
}

variable "lambda_function_handler" {
  default = "com.deinersoft.zipster.APIRequestHandler"
}

variable "lambda_runtime" {
  default = "java8"
}

variable "api_env_stage_name" {
  default = "reference_implementation"
}