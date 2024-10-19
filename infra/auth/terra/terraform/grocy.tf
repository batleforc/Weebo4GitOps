resource "zitadel_project" "grocy" {
  org_id                 = zitadel_org.weebo.id
  name                   = "grocy"
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_project_role" "grocy_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.grocy.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}
resource "zitadel_project_role" "grocy_user" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.grocy.id
  role_key     = "user"
  display_name = "User"
  group        = "user"
}

resource "zitadel_application_oidc" "grocy_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.grocy.id
  name                        = "grocy"
  redirect_uris               = ["https://meal.weebo.fr/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://meal.weebo.fr"]
}

resource "kubernetes_secret" "grocy_keyid" {
  metadata {
    name      = "grocy-auth"
    namespace = "grocy"
  }
  data = {
    "values.yaml" = <<EOF
config:
  clientID: ${zitadel_application_oidc.grocy_app.client_id}
  clientSecret: ${zitadel_application_oidc.grocy_app.client_secret}
    EOF

  }
}
