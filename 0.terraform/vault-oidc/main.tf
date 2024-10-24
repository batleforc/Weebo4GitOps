terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

variable "vault_token" {
  description = "The token to authenticate with Vault"
  type        = string
}

variable "oidc_client_id" {
  description = "The OIDC client ID"
  type        = string
}

variable "oidc_client_secret" {
  description = "The OIDC client secret"
  type        = string
}

provider "vault" {
  token   = var.vault_token
  address = "https://localhost:8200"
}


resource "vault_jwt_auth_backend" "weebo" {
  description        = "Login with WeeboAuth"
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "https://login.weebo.fr"
  oidc_client_id     = var.oidc_client_id
  oidc_client_secret = var.oidc_client_secret
  bound_issuer       = "https://login.weebo.fr"
}

resource "vault_jwt_auth_backend_role" "manager" {
  backend        = vault_jwt_auth_backend.weebo.path
  role_name      = "admin"
  token_policies = ["oidc_manager"]

  user_claim            = "email"
  role_type             = "oidc"
  groups_claim          = "roles"
  allowed_redirect_uris = ["https://localhost:8200/ui/vault/auth/oidc/oidc/callback", "http://localhost:8250/oidc/callback"]
}
