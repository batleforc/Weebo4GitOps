resource "zitadel_project" "longhorn" {
  org_id                 = zitadel_org.weebo.id
  name                   = "longhorn"
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_project_role" "longhorn_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.longhorn.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}

resource "zitadel_application_oidc" "longhorn_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.longhorn.id
  name                        = "longhorn"
  redirect_uris               = ["https://horn.weebo.fr/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://horn.weebo.fr"]
}

resource "kubernetes_secret" "longhorn_keyid" {
  metadata {
    name      = "longhorn-auth"
    namespace = "longhorn-system"
  }
  data = {
    "values.yaml" = <<EOF
config:
  clientID: ${zitadel_application_oidc.longhorn_app.client_id}
  clientSecret: ${zitadel_application_oidc.longhorn_app.client_secret}
    EOF

  }
}
