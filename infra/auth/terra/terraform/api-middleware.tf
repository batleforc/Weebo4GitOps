resource "zitadel_project" "middle-api" {
  org_id                 = zitadel_org.weebo.id
  name                   = "Api-Middleware"
  project_role_assertion = true
}

resource "zitadel_project_role" "middle-api-discord" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.middle-api.id
  role_key     = "discord"
  display_name = "Discord"
  group        = "discord"
}

resource "zitadel_project_role" "middle-api-gotify" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.middle-api.id
  role_key     = "gotify"
  display_name = "Gotify"
  group        = "gotify"
}



resource "zitadel_application_api" "middle-api-main" {
  org_id           = zitadel_org.weebo.id
  project_id       = zitadel_project.middle-api.id
  name             = "main"
  auth_method_type = "API_AUTH_METHOD_TYPE_PRIVATE_KEY_JWT"
}

resource "zitadel_application_key" "middle-api-main-key" {
  org_id          = zitadel_org.weebo.id
  project_id      = zitadel_project.middle-api.id
  app_id          = zitadel_application_api.middle-api-main.id
  key_type        = "KEY_TYPE_JSON"
  expiration_date = "2500-12-31T23:59:59Z"
}

resource "kubernetes_secret_v1" "middle-api-main-secret" {
  metadata {
    name      = "api-middleware-auth"
    namespace = "api-middleware"
  }
  data = yamldecode(zitadel_application_key.middle-api-main-key.key_details)
}


resource "zitadel_machine_user" "m2m-alertmanager" {
  org_id            = zitadel_org.weebo.id
  user_name         = "alertmanager@middleware.weebo.fr"
  name              = "alertmanager"
  description       = "Alertmanager notification user"
  access_token_type = "ACCESS_TOKEN_TYPE_BEARER"
}

resource "zitadel_personal_access_token" "m2m-alertmanager-token" {
  org_id          = zitadel_org.weebo.id
  user_id         = zitadel_machine_user.m2m-alertmanager.id
  expiration_date = "2519-04-01T08:45:00Z"
}

resource "kubernetes_secret_v1" "m2m-alertmanager-token-secret" {
  metadata {
    name      = "alertmanager-auth"
    namespace = "api-middleware"
  }
  data = {
    user  = zitadel_machine_user.m2m-alertmanager.user_name
    token = zitadel_personal_access_token.m2m-alertmanager-token.token
  }
}
