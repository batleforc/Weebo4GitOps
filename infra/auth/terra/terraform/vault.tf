resource "zitadel_project" "vault" {
  org_id                 = zitadel_org.weebo.id
  name                   = "vault"
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_project_role" "vault_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.vault.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}

resource "zitadel_application_oidc" "vault_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.vault.id
  name                        = "vault"
  redirect_uris               = ["https://localhost:8250/oidc/callback", "https://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  dev_mode                    = true
  additional_origins          = ["https://localhost:8250", "https://localhost:8200"]
}

resource "kubernetes_secret_v1" "vault_keyid" {
  metadata {
    name      = "vault-auth"
    namespace = "vault"
  }
  data = {
    clientID = zitadel_application_oidc.eclipse_che.client_id
    secret   = zitadel_application_oidc.eclipse_che.client_secret
  }
}
