terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
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

resource "vault_generic_secret" "zitadel_pg" {
  path = "secret/zitadel/pg"
  data_json = jsonencode(
    {
        password_admin = var.adminpassword
        password_user = var.userpassword
        masterkey = var.masterkey
    }
  )
}