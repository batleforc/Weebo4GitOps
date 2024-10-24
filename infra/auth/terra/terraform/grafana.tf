resource "zitadel_project" "grafana" {
  org_id                 = zitadel_org.weebo.id
  name                   = "grafana"
  project_role_assertion = true
}

resource "zitadel_project_role" "grafana_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.grafana.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}

resource "zitadel_project_role" "grafana_editor" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.grafana.id
  role_key     = "editor"
  display_name = "editor"
  group        = "editor"
}
resource "zitadel_project_role" "grafana_user" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.grafana.id
  role_key     = "user"
  display_name = "user"
  group        = "user"
}

resource "zitadel_application_oidc" "grafana_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.grafana.id
  name                        = "grafana"
  redirect_uris               = ["https://grafana.weebo.fr/login/generic_oauth"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://grafana.weebo.fr"]
}

resource "kubernetes_secret_v1" "grafana_keyid" {
  metadata {
    name      = "grafana-auth"
    namespace = "monitoring"
  }
  data = {
    keyid = zitadel_application_oidc.grafana_app.client_id
    pkce  = true
  }
}
