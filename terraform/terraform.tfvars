// Harness Platform
account_id = "EeRjnXTnS4GrLG5VNNJZUw"
org_id     = "sandbox"
project_id = "Titra"

// Environments, Infrastructures, & Services
environments = {
  dev = {
    env_name       = "Dev"
    env_identifier = "dev"
    env_type       = "PreProduction"
    infrastructures = {
      boutique = {
        infra_name       = "Boutique Dev"
        infra_identifier = "boutiquedev"
        namespace        = "boutique-dev"
        services = {
          boutique_pm = {
            serv_name           = "Boutique - PMService"
            serv_identifier     = "Boutique_PMService_dev"
            artifact_identifier = "tbd"
            artifact_tag        = "tbd"
          }
        }
      }
      devsecops = {
        infra_name       = "DevSecOps"
        infra_identifier = "devsecops"
        namespace        = "devsecops"
        services = {
          devsec_frontend = {
            serv_name           = "DevSecOps - Frontend"
            serv_identifier     = "DevSecOps_Frontend"
            artifact_identifier = "frontend"
            artifact_tag        = "0.0.<+pipeline.sequenceId>"
          }
          devsec_backend = {
            serv_name           = "DevSecOps - Backend"
            serv_identifier     = "DevSecOps_Backend"
            artifact_identifier = "backend"
            artifact_tag        = "backend-latest"
          }
        }
      }
      petclinic = {
        infra_name       = "PetClinic Dev"
        infra_identifier = "petclinicdev"
        namespace        = "petclinic-dev"
        services = {
          petclinic = {
            serv_name           = "PetClinic"
            serv_identifier     = "PetClinic"
            artifact_identifier = "petclinic"
            artifact_tag        = "0.0.4"
          }
        }
      }
    }
  }
  qa = {
    env_name       = "QA"
    env_identifier = "qa"
    env_type       = "PreProduction"
    infrastructures = {
      boutique = {
        infra_name       = "Boutique QA"
        infra_identifier = "boutiqueqa"
        namespace        = "boutique-qa"
        services = {
          boutique_pm = {
            serv_name           = "Boutique - PMService"
            serv_identifier     = "Boutique_PMSerivce_qa"
            artifact_identifier = "tbd"
            artifact_tag        = "tbd"
          }
        }
      }
      petclinic = {
        infra_name       = "PetClinic QA"
        infra_identifier = "petclinicqa"
        namespace        = "petclinic-qa"
        services = {
          petclinic = {
            serv_name           = "PetClinic"
            serv_identifier     = "PetClinic"
            artifact_identifier = "petclinic"
            artifact_tag        = "0.0.4"
          }
        }
      }
    }
  }
  prod = {
    env_name       = "Prod"
    env_identifier = "prod"
    env_type       = "Production"
    infrastructures = {
      boutique = {
        infra_name       = "Boutique Prod"
        infra_identifier = "boutiqueprod"
        namespace        = "boutique-prod"
        services = {
          boutique_pm = {
            serv_name           = "Boutique - PMService"
            serv_identifier     = "Boutique_PMSerivce_prod"
            artifact_identifier = "tbd"
            artifact_tag        = "tbd"
          }
        }
      }
      petclinic_prod1 = {
        infra_name       = "PetClinic Prod1"
        infra_identifier = "petclinicprod1"
        namespace        = "petclinic-prod1"
        services = {
          petclinic = {
            serv_name           = "PetClinic"
            serv_identifier     = "PetClinic"
            artifact_identifier = "petclinic"
            artifact_tag        = "0.0.4"
          }
        }
      }
      petclinic_prod2 = {
        infra_name       = "PetClinic Prod2"
        infra_identifier = "petclinicprod2"
        namespace        = "petclinic-prod2"
        services = {
          petclinic = {
            serv_name           = "PetClinic"
            serv_identifier     = "PetClinic"
            artifact_identifier = "petclinic"
            artifact_tag        = "0.0.4"
          }
        }
      }
    }
  }
}

// Repos
repos = {
  devsecops = {
    repo_id        = "devsecops"
    default_branch = "main"
    source_repo    = "harness-community/unscripted-workshop-2024"
    source_type    = "github"
  }
}

// JDBC Connectors
jdbc_connectors = {
  pet_dev = {
    jdbc_id   = "PetClinic_Dev"
    jdbc_name = "PetClinic - Dev"
    jdbc_url  = "jdbc:postgresql://postgres-dev.postgresql.svc.cluster.local/petclinic"
  }
  pet_qa = {
    jdbc_id   = "PetClinic_QA"
    jdbc_name = "PetClinic - QA"
    jdbc_url  = "jdbc:postgresql://postgres-qa.postgresql.svc.cluster.local/petclinic"
  }
  pet_prod1 = {
    jdbc_id   = "PetClinic_Prod1"
    jdbc_name = "PetClinic - Prod1"
    jdbc_url  = "jdbc:postgresql://postgres-prod1.postgresql.svc.cluster.local/petclinic"
  }
  pet_prod2 = {
    jdbc_id   = "PetClinic_Prod2"
    jdbc_name = "PetClinic - Prod2"
    jdbc_url  = "jdbc:postgresql://postgres-prod2.postgresql.svc.cluster.local/petclinic"
  }
}
