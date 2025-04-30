variable "aws_region" {
  description = "AWS Region to deploy infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "prefect_api_secret_name" {
  description = "Name of AWS Secrets Manager secret containing Prefect API Key"
  type        = string
  default     = "prefect-api-key"
}

variable "prefect_account_id" {
  description = "Your Prefect Cloud Account ID"
  type        = string
}

variable "prefect_workspace_id" {
  description = "Your Prefect Workspace ID"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Name = "prefect-ecs"
  }
}