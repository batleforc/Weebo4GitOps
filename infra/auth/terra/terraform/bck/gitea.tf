resource "zitadel_project" "gitea" {
  org_id                 = zitadel_org.weebo.id
  name                   = "gitea"
  project_role_assertion = true
}

resource "zitadel_project_role" "gitea_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.gitea.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}
resource "zitadel_project_role" "gitea_user" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.gitea.id
  role_key     = "user"
  display_name = "User"
  group        = "user"
}

resource "zitadel_application_oidc" "gitea_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.gitea.id
  name                        = "gitea"
  redirect_uris               = ["https://git.weebo.fr/user/oauth2/zitadel/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://git.weebo.fr"]
}

resource "kubernetes_secret_v1" "gitea_keyid" {
  metadata {
    name      = "gitea-auth"
    namespace = "gitea"
  }
  data = {
    key    = zitadel_application_oidc.gitea_app.client_id
    secret = zitadel_application_oidc.gitea_app.client_secret
  }
}
