// Version requirements or limitations 
// As well as location to define remote backend for storing state
terraform {

  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.31.8" #"0.40.2"
    }
  }

  backend "http" {
    address        = "https://app.harness.io/gateway/iacm/api/orgs/sandbox/projects/Titra/workspaces/Titra/terraform-backend?accountIdentifier=EeRjnXTnS4GrLG5VNNJZUw"
    username       = "harness"
    lock_address   = "https://app.harness.io/gateway/iacm/api/orgs/sandbox/projects/Titra/workspaces/Titra/terraform-backend/lock?accountIdentifier=EeRjnXTnS4GrLG5VNNJZUw"
    lock_method    = "POST"
    unlock_address = "https://app.harness.io/gateway/iacm/api/orgs/sandbox/projects/Titra/workspaces/Titra/terraform-backend/lock?accountIdentifier=EeRjnXTnS4GrLG5VNNJZUw"
    unlock_method  = "DELETE"
  }
}
