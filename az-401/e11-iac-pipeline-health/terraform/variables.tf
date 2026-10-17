variable "resource_group_name" {
  type        = string
  description = "Existing resource group for the shop."
  default     = "rg-pinecone-prod"
}

variable "environment_name" {
  type        = string
  description = "Short environment name, e.g. dev or prod."
  default     = "prod"
}

variable "plan_sku" {
  type        = string
  description = "App Service plan SKU. Deployment slots need Standard or higher."
  default     = "S1"
}
