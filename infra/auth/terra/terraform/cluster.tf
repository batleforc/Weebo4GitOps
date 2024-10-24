resource "zitadel_project" "cluster" {
  org_id                 = zitadel_org.weebo.id
  name                   = "cluster"
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_project_role" "cluster_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.cluster.id
  role_key     = "admin"
  display_name = "Admin"
  group        = "admin"
}

resource "zitadel_project_role" "cluster_dev" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.cluster.id
  role_key     = "dev"
  display_name = "Dev"
  group        = "dev"
}

resource "zitadel_project_role" "cluster_user" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.cluster.id
  role_key     = "user"
  display_name = "User"
  group        = "user"
}

resource "zitadel_project_role" "cluster_gamer" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.cluster.id
  role_key     = "gamer"
  display_name = "gamer"
  group        = "gamer"
}

# PKCE
resource "zitadel_application_oidc" "cluster_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.cluster.id
  name                        = "cluster"
  redirect_uris               = ["http://localhost:8000", "http://localhost:18000", "https://*.che.dev.weebo.fr/*", "https://che.dev.weebo.fr/*"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  dev_mode                    = true
  additional_origins          = ["http://localhost:8000", "http://localhost:18000", "https://che.dev.weebo.fr", "https://*.che.dev.weebo.fr"]
}

resource "kubernetes_secret" "cluster_keyid" {
  metadata {
    name      = "cluster-auth"
    namespace = "zitadel"
  }
  data = {
    clientID = zitadel_application_oidc.cluster_app.client_id
  }
}

# Eclipse che
resource "zitadel_application_oidc" "eclipse_che" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.cluster.id
  name                        = "eclipse-che"
  redirect_uris               = ["https://*.che.dev.weebo.fr/oauth/callback", "https://che.dev.weebo.fr/oauth/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  dev_mode                    = true
  additional_origins          = ["https://che.dev.weebo.fr", "https://*.che.dev.weebo.fr"]
}

resource "kubernetes_secret" "che_keyid" {
  metadata {
    name      = "che-auth"
    namespace = "zitadel"
  }
  data = {
    clientID = zitadel_application_oidc.eclipse_che.client_id
    secret   = zitadel_application_oidc.eclipse_che.client_secret
  }
}
