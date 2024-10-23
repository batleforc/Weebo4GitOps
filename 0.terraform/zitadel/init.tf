terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.33.0"
    }
  }
}

variable "adminpassword" {
  type = string
}

variable "userpassword" {
  type = string
}

variable "masterkey" {
  type = string
}

provider "vault" {
  address = "https://localhost:8200"
}

provider "kubernetes" {
  config_path = "../../kubeconfig.yaml"
}

resource "vault_generic_secret" "zitadel_pg" {
  path = "secret/zitadel/pg"
  data_json = jsonencode(
    {
      password_admin = var.adminpassword
      password_user  = var.userpassword
      masterkey      = var.masterkey
    }
  )
}

# Because zitadel doesn't handle everything in a way where i can use the vault provider, i have to use the kubernetes provider
resource "kubernetes_secret" "zitadel_secret" {
  metadata {
    name      = "zitadel-zitadel"
    namespace = "zitadel"
  }
  data = {
    "masterkey"   = var.masterkey
    "config-yaml" = <<EOT
      Database:
        Postgres:
          User:
            Password: "${var.userpassword}"
          Admin:
            Password: "${var.adminpassword}"
    EOT
  }
}
