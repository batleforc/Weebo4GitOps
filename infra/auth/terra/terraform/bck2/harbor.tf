resource "zitadel_project" "harbor" {
  org_id                 = zitadel_org.weebo.id
  name                   = "harbor"
  project_role_assertion = true
}

resource "zitadel_project_role" "harbor_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.harbor.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}

resource "zitadel_application_oidc" "harbor_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.harbor.id
  name                        = "harbor"
  redirect_uris               = ["https://harbor.weebo.fr/c/oidc/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://harbor.weebo.fr"]
}

resource "kubernetes_secret_v1" "harbor_secret" {
  metadata {
    name      = "harbor-auth"
    namespace = "harbor"
  }
  data = {
    TF_VAR_oidc_key    = zitadel_application_oidc.harbor_app.client_id
    TF_VAR_oidc_secret = zitadel_application_oidc.harbor_app.client_secret
  }
}
