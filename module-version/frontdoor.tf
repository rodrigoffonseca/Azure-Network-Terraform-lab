#create azure front door 
resource "azurerm_frontdoor" "azfrontdoor" {
  name                                         = var.frontdoorname
  location                                     = var.location
  resource_group_name                          = azurerm_resource_group.rg.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "exampleRoutingRule1"
    accepted_protocols = ["Http"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["exampleFrontendEndpoint1"]
    forwarding_configuration {
      forwarding_protocol = "HttpOnly"
      backend_pool_name   = "exampleBackend"
    }
  }

  backend_pool_load_balancing {
    name = "exampleLoadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "exampleHealthProbeSetting1"
  }

  backend_pool {
    name = "exampleBackend"
    backend {
      host_header = "mytest"
      address     = azurerm_public_ip.azfirewallpip.ip_address
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = "exampleLoadBalancingSettings1"
    health_probe_name   = "exampleHealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = "exampleFrontendEndpoint1"
    host_name                         = "${var.frontdoorname}.azurefd.net"
    custom_https_provisioning_enabled = false
  }
}