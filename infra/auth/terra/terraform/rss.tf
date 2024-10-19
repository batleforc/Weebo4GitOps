resource "zitadel_project" "rss" {
  org_id                 = zitadel_org.weebo.id
  name                   = "rss"
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_project_role" "rss_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.rss.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}
resource "zitadel_project_role" "rss_user" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.rss.id
  role_key     = "user"
  display_name = "User"
  group        = "user"
}

resource "zitadel_application_oidc" "rss_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.rss.id
  name                        = "rss"
  redirect_uris               = ["https://rss.weebo.fr/oauth2/oidc/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://rss.weebo.fr"]
}

resource "kubernetes_secret_v1" "rss_keyid" {
  metadata {
    name      = "rss-auth"
    namespace = "rss"
  }
  data = {
    key    = zitadel_application_oidc.rss_app.client_id
    secret = zitadel_application_oidc.rss_app.client_secret
  }
}
