// Define the resources to create
// Provisions the following resources: 
//    K8s Connector, Environments, Infrastructures
//    Services, Monitored Services, Code Repo
//    Pipeline, Prometheus Connector
locals {
  k8s_connector_desc   = "Connector for se-demo K8s cluster"
  delegate_selector    = "se-demo-account-delegate"
  k8s_connector_id     = "se_demo_k8s"
  k8s_connector_name   = "SE Demo K8s"
  primary_demo_project = "Platform_Engineering"
  environment_infrastructures_list = flatten([
    for env_key, env_value in var.environments : [
      for infra_key, infra_value in env_value.infrastructures : {
        env_key     = env_key
        env_value   = env_value
        infra_key   = infra_key
        infra_value = infra_value
      }
    ]
  ])
  environment_infrastructures = {
    for item in local.environment_infrastructures_list :
    "${item.env_key}_${item.infra_key}" => {
      env_key   = item.env_key
      env       = item.env_value
      infra_key = item.infra_key
      infra     = item.infra_value
    }
  }
  services_map = {
    for s in flatten([
      for env_key, env_value in var.environments : [
        for infra_key, infra_value in env_value.infrastructures : [
          for service_key, service_value in infra_value.services : {
            key           = "${env_key}_${infra_key}_${service_key}"
            env_key       = env_key
            env_value     = env_value
            infra_key     = infra_key
            infra_value   = infra_value
            service_key   = service_key
            service_value = service_value
          }
        ]
      ]
      ]) : s.key => {
      env_key       = s.env_key
      env_value     = s.env_value
      infra_key     = s.infra_key
      infra_value   = s.infra_value
      service_key   = s.service_key
      service_value = s.service_value
    }
  }
}

// K8s Connector
resource "harness_platform_connector_kubernetes" "proj_connector" {
  identifier  = local.k8s_connector_id
  name        = local.k8s_connector_name
  org_id      = var.org_id
  project_id  = var.project_id
  description = local.k8s_connector_desc

  inherit_from_delegate {
    delegate_selectors = [local.delegate_selector]
  }
}

// Environments
resource "harness_platform_environment" "environment" {
  for_each = var.environments

  identifier = each.value.env_identifier
  name       = each.value.env_name
  org_id     = var.org_id
  project_id = var.project_id
  type       = each.value.env_type
}

// Infrastructures
resource "harness_platform_infrastructure" "infrastructure" {
  for_each = local.environment_infrastructures

  identifier      = each.value.infra.infra_identifier
  name            = each.value.infra.infra_name
  org_id          = var.org_id
  project_id      = var.project_id
  env_id          = harness_platform_environment.environment[each.value.env_key].identifier
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = <<-EOT
    infrastructureDefinition:
      name: ${each.value.infra.infra_name}
      identifier: ${each.value.infra.infra_identifier}
      description: ""
      tags:
        owner: ${var.org_id}
      orgIdentifier: ${var.org_id}
      projectIdentifier: ${var.project_id}
      environmentRef: ${harness_platform_environment.environment[each.value.env_key].identifier}
      deploymentType: Kubernetes
      type: KubernetesDirect
      spec:
        connectorRef: ${harness_platform_connector_kubernetes.proj_connector.identifier}
        namespace: ${each.value.infra.namespace}
        releaseName: release-<+INFRA_KEY>
      allowSimultaneousDeployments: true
  EOT
}

// Services
resource "harness_platform_service" "boutiquepm_service" {
  identifier = "Boutique_PMSerivce"
  name       = "Boutique - PMService"
  org_id     = var.org_id
  project_id = var.project_id
  yaml       = <<-EOT
    service:
      name: Boutique - PMService
      identifier: Boutique_PMSerivce
      orgIdentifier: ${var.org_id}
      projectIdentifier: ${var.project_id}
      serviceDefinition:
        spec:
          artifacts:
            primary:
              primaryArtifactRef: <+input>
              sources:
                - spec:
                    connectorRef: account.harnessImage
                    imagePath: seworkshop/boutique-pmservice
                    tag: <+pipeline.stages.Build_Test_Push.spec.execution.steps.ProvenanceStepGroup_Build_and_push_image_to_DockerHub.steps.Build_and_push_image_to_DockerHub.artifact_ProvenanceStepGroup_Build_and_push_image_to_DockerHub_Build_and_push_image_to_DockerHub.stepArtifacts.publishedImageArtifacts[0].tag>
                    digest: ""
                  identifier: boutique_pmservice
                  type: DockerRegistry
          manifests:
            - manifest:
                identifier: boutique_pm_service
                type: K8sManifest
                spec:
                  store:
                    type: Github
                    spec:
                      connectorRef: account.Github
                      gitFetchType: Branch
                      paths:
                        - boutique/15-pmservice.yaml
                      repoName: wings-software/e2e-enterprise-demo
                      branch: main
                  valuesPaths:
                    - boutique/values.yaml
                  skipResourceVersioning: false
                  enableDeclarativeRollback: false
          variables:
            - name: cart_service_password
              type: Secret
              description: ""
              required: false
              value: Cart_Service_Password_Dev
        type: Kubernetes
  EOT
}

resource "harness_platform_service" "devsecops_services" {
  for_each = {
    for key, value in local.services_map :
    key => value
    if value.infra_key == "devsecops"
  }

  identifier = each.value.service_value.serv_identifier
  name       = each.value.service_value.serv_name
  org_id     = var.org_id
  project_id = var.project_id
  yaml       = <<-EOT
    service:
      name: ${each.value.service_value.serv_name}
      identifier: ${each.value.service_value.serv_identifier}
      orgIdentifier: ${var.org_id}
      projectIdentifier: ${var.project_id}
      serviceDefinition:
        spec:
          manifests:
            - manifest:
                identifier: ${each.value.service_value.artifact_identifier}
                type: K8sManifest
                spec:
                  store:
                    type: HarnessCode
                    spec:
                      gitFetchType: Branch
                      paths:
                        - harness-deploy/${each.value.service_value.artifact_identifier}/manifests
                      repoName: devsecops
                      branch: main
                  valuesPaths:
                    - harness-deploy/${each.value.service_value.artifact_identifier}/values.yaml
                  skipResourceVersioning: false
                  enableDeclarativeRollback: false
          artifacts:
            primary:
              primaryArtifactRef: <+input>
              sources:
                - spec:
                    connectorRef: account.harnessImage
                    imagePath: seworkshop/devsecops-demo
                    tag: ${each.value.service_value.artifact_tag}
                    digest: ""
                  identifier: ${each.value.service_value.artifact_identifier}
                  type: DockerRegistry
        type: Kubernetes
  EOT
}

resource "harness_platform_service" "petclinic_service" {
  identifier = "PetClinic"
  name       = "PetClinic"
  org_id     = var.org_id
  project_id = var.project_id
  yaml       = <<-EOT
    service:
      name: PetClinic
      identifier: PetClinic
      orgIdentifier: ${var.org_id}
      projectIdentifier: ${var.project_id}
      serviceDefinition:
        spec:
          manifests:
            - manifest:
                identifier: petclinic
                type: K8sManifest
                spec:
                  store:
                    type: Github
                    spec:
                      connectorRef: Github
                      gitFetchType: Branch
                      paths:
                        - harness-deploy/petclinic/manifests
                      repoName: jtitra/harness-petclinic
                      branch: main
                  valuesPaths:
                    - harness-deploy/petclinic/values.yaml
                  skipResourceVersioning: false
                  enableDeclarativeRollback: false
          artifacts:
            primary:
              primaryArtifactRef: <+input>
              sources:
                - spec:
                    connectorRef: account.GCP_Sales_Admin
                    repositoryType: docker
                    project: sales-209522
                    region: us-east1
                    repositoryName: titra
                    package: petclinic
                    version: "0.0.4"
                    digest: ""
                  identifier: petclinic
                  type: GoogleArtifactRegistry
        type: Kubernetes
  EOT
}

// Secrets
resource "harness_platform_secret_text" "cart_service_secret" {
  identifier  = "Cart_Service_Password_Dev"
  name        = "Cart Service Password Dev"
  org_id      = var.org_id
  project_id  = var.project_id
  description = "Example secret used by boutique/values.yaml and boutique/06-frontend.yaml for demonstrating using secrets in pipeline and redacting secrets in logs"

  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = "devpassword"
}

// Monitored Services
resource "harness_platform_monitored_service" "boutique_monitored_services" {
  for_each = {
    for key, value in local.services_map :
    key => value
    if value.infra_key == "boutique"
  }

  org_id     = var.org_id
  project_id = var.project_id
  identifier = each.value.service_value.serv_identifier
  request {
    name            = each.value.service_value.serv_name
    type            = "Application"
    service_ref     = harness_platform_service.boutiquepm_service.identifier
    environment_ref = harness_platform_environment.environment[each.value.env_key].identifier
    health_sources {
      name       = "Prometheus"
      identifier = "prometheus"
      type       = "Prometheus"
      spec = jsonencode({
        connectorRef = "prometheus"
        metricDefinitions = [
          {
            identifier = "Prometheus_Metric",
            metricName = "Prometheus Metric",
            riskProfile = {
              riskCategory = "Performance_Other"
              thresholdTypes = [
                "ACT_WHEN_HIGHER"
              ]
            }
            analysis = {
              liveMonitoring = {
                enabled = true
              }
              deploymentVerification = {
                enabled                  = true
                serviceInstanceFieldName = "pod"
              }
            }
            query         = "avg(container_cpu_system_seconds_total { namespace=\"${each.value.infra_value.namespace}\" , container=\"test\"})"
            groupName     = "Infrastructure"
            isManualQuery = true
          }
        ]
      })
    }
  }
}

resource "harness_platform_monitored_service" "devsecops_monitored_services" {
  for_each = {
    for key, value in local.services_map :
    key => value
    if value.infra_key == "devsecops"
  }

  org_id     = var.org_id
  project_id = var.project_id
  identifier = "${each.value.service_value.serv_identifier}_${each.value.env_key}"
  request {
    name            = each.value.service_value.serv_name
    type            = "Application"
    service_ref     = harness_platform_service.devsecops_services[each.key].identifier
    environment_ref = harness_platform_environment.environment[each.value.env_key].identifier
    health_sources {
      name       = "Prometheus"
      identifier = "prometheus"
      type       = "Prometheus"
      spec = jsonencode({
        connectorRef = "prometheus"
        metricDefinitions = [
          {
            identifier = "Prometheus_Metric",
            metricName = "Prometheus Metric",
            riskProfile = {
              riskCategory = "Performance_Other"
              thresholdTypes = [
                "ACT_WHEN_HIGHER"
              ]
            }
            analysis = {
              liveMonitoring = {
                enabled = true
              }
              deploymentVerification = {
                enabled                  = true
                serviceInstanceFieldName = "pod"
              }
            }
            query         = "avg(container_cpu_system_seconds_total { namespace=\"${each.value.infra_value.namespace}\" , container=\"test\"})"
            groupName     = "Infrastructure"
            isManualQuery = true
          }
        ]
      })
    }
  }
}

// Code Repo
resource "harness_platform_repo" "proj_repos" {
  for_each = var.repos

  identifier     = each.value.repo_id
  org_id         = var.org_id
  project_id     = var.project_id
  default_branch = each.value.default_branch
  source {
    repo = each.value.source_repo
    type = each.value.source_type
  }
}

// Prometheus Connector
resource "harness_platform_connector_prometheus" "prometheus" {
  identifier         = "prometheus"
  name               = "Prometheus"
  org_id             = var.org_id
  project_id         = var.project_id
  description        = "Connector to SE Demo Cluster Prometheus Instance"
  url                = "http://prometheus-k8s.monitoring.svc.cluster.local:9090/"
  delegate_selectors = [local.delegate_selector]
}

// JDBC Connectors
resource "harness_platform_connector_jdbc" "test" {
  for_each = var.jdbc_connectors

  identifier         = each.value.jdbc_id
  name               = each.value.jdbc_name
  org_id             = var.org_id
  project_id         = var.project_id
  url                = each.value.jdbc_url
  delegate_selectors = [local.delegate_selector]
  credentials {
    username     = "petclinic"
    password_ref = "petclinic-db"
  }
}
