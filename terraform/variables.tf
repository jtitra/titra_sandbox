// Define Valid Variables
// Harness Platform
variable "account_id" {
  type = string
}

variable "org_id" {
  type = string
}

variable "project_id" {
  type = string
}

variable "api_key" {
  type      = string
  sensitive = true
}

// Environments, Infrastructures, & Services
variable "environments" {
  type = map(object({
    env_name       = string
    env_identifier = string
    env_type       = string
    infrastructures = map(object({
      infra_name       = string
      infra_identifier = string
      namespace        = string
      services = map(object({
        serv_name           = string
        serv_identifier     = string
        artifact_identifier = string
        artifact_tag        = string
      }))
    }))
  }))
}

// Repos
variable "repos" {
  type = map(object({
    repo_id        = string
    default_branch = string
    source_repo    = string
    source_type    = string
  }))
}

// JDBC Connectors
variable "jdbc_connectors" {
  type = map(object({
    jdbc_id   = string
    jdbc_name = string
    jdbc_url  = string
  }))
}
