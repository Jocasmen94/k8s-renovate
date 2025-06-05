locals {
  location            = "centralus"
  resource_group_name = "prod-payments"
  environment         = "prod"
  cluster_name        = "${local.environment}-payments-cluster"
  additional_tags = {
    Owner      = "SRE"
    Expires    = "Never"
    Department = "Engineering"
    Billing    = "prod-payments"
  }

  aks_clusters = [
    {
      resource_group_name   = local.resource_group_name
      cluster_name          = local.cluster_name
      enable_cert_manager   = true
      cert_manager_version  = "1.17.1"
      enable_cluster_issuer = true
      cluster_issuers = [
        {
          name                    = "letsencrypt"
          issuerName              = "letsencrypt"
          email                   = var.cloudflare_email
          acmeApi                 = "https://acme-v02.api.letsencrypt.org/directory"
          privateKeySecretRefName = "letsencrypt-private-key"
          cloudflareApiTokenName  = "cloudflare-api-token-secret"
          cloudflareApiToken      = var.cloudflare_api_token
        }
      ]
      enable_ingress_controller = true
      ingress_nginx_controllers = [
        {
          name                       = "ingress-nginx-controller"
          ingress_nginx_version      = "4.12.3"
          ingress_class_name         = "nginx"
          internal                   = false
          admission_webhooks_enabled = false
          image_tag                  = "v1.11.5"
        }
      ]
      enable_external_dns = true
      external_dns_config = {
        version                  = "6.24.1"  # Actualizado a la versión más reciente (7 May 2025)
        use_cloudflare_api_token = true
        email                    = var.cloudflare_email
        cloudflare_api_token     = var.cloudflare_api_token
        helm_config              = {
          chart = "external-dns"
        }
      }
      enable_datadog_operator = true
      datadog_operator_helm_config = {
        datadog_operator_chart_version = "2.9.1"  # Pasado como variable
        api_key                        = var.datadog_api_key
        app_key                        = var.datadog_app_key
        enable_datadog_monitor         = true
      }
      datadog_agent_helm_config = {
        datadog_agent_chart_version = "3.111.1"  # Pasado como variable
        api_key                     = var.datadog_api_key
        app_key                     = var.datadog_app_key
        cluster_name                = local.cluster_name
        apm_port_enabled            = true
        logs_enabled                = true
        container_include_logs      = "kube_namespace:payments"
        cluster_agent_image_tag     = "7.64.3"  # Actualizado a versión compatible
        agents_image_tag            = "7.64.3"  # Actualizado a versión compatible
        set_values = [
          {
            name  = "datadog.securityAgent.runtime.enabled"
            value = true
          },
          {
            name  = "datadog.securityAgent.compliance.enabled"
            value = true
          },
          {
            name  = "datadog.securityAgent.compliance.host_benchmarks.enabled"
            value = true
          },
          {
            name  = "datadog.containerImageCollection.enabled"
            value = true
          },
          {
            name  = "datadog.sbom.containerImage.enabled"
            value = true
          },
          {
            name  = "datadog.sbom.host.enabled"
            value = true
          },
          {
            name  = "datadog.otlp.receiver.protocols.grpc.enabled"
            value = true
          },
          {
            name  = "datadog.otlp.receiver.protocols.http.enabled"
            value = true
          }
        ]
      }
      enable_doppler      = true
      doppler_helm_config = {
        version = "1.2.3"  # Especificamos la versión del chart de Doppler, lo agarra dinamicamente aqui la version
      }
    }
  ]
}