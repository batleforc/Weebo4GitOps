resource "zitadel_project" "tekton" {
  org_id                 = zitadel_org.weebo.id
  name                   = "tekton"
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_project_role" "tekton_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.tekton.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}
resource "zitadel_project_role" "tekton_user" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.tekton.id
  role_key     = "user"
  display_name = "User"
  group        = "user"
}

resource "zitadel_application_oidc" "tekton_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.tekton.id
  name                        = "tekton"
  redirect_uris               = ["https://cicd.weebo.fr/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://cicd.weebo.fr"]
}

resource "kubernetes_secret" "tekton_keyid" {
  metadata {
    name      = "tekton-auth"
    namespace = "tekton-pipelines"
  }
  data = {
    "values.yaml" = <<EOF
config:
  clientID: ${zitadel_application_oidc.tekton_app.client_id}
  clientSecret: ${zitadel_application_oidc.tekton_app.client_secret}
    EOF

  }
}

resource "zitadel_application_oidc" "frontend" {
  project_id                  = zitadel_project.tekton.id
  org_id                      = zitadel_org.weebo.id
  name                        = "frontend"
  redirect_uris               = ["https://oauth.pstmn.io/v1/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  dev_mode                    = true
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://oauth.pstmn.io"]
}


resource "kubernetes_secret_v1" "postman_keyid" {
  metadata {
    name      = "postman-auth"
    namespace = "tekton-pipelines"
  }
  data = {
    key    = zitadel_application_oidc.frontend.client_id
    secret = zitadel_application_oidc.frontend.client_secret
  }
}
