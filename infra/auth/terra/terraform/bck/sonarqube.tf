resource "zitadel_project" "sonarqube" {
  org_id                 = zitadel_org.weebo.id
  name                   = "sonarqube"
  project_role_assertion = true
  project_role_check     = true
}

resource "zitadel_project_role" "sonarqube_admin" {
  org_id       = zitadel_org.weebo.id
  project_id   = zitadel_project.sonarqube.id
  role_key     = "sonar-administrators"
  display_name = "sonar-administrators"
  group        = "sonar-administrators"
}

resource "zitadel_application_oidc" "sonarqube_app" {
  org_id                      = zitadel_org.weebo.id
  project_id                  = zitadel_project.sonarqube.id
  name                        = "sonarqube"
  redirect_uris               = ["https://sonar.weebo.fr/oauth2/callback","https://qube.weebo.fr/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_BASIC"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  additional_origins          = ["https://sonar.weebo.fr","https://qube.weebo.fr"]
}

resource "kubernetes_secret" "sonarqube_keyid" {
  metadata {
    name      = "sonarqube-auth"
    namespace = "sonarqube2"
  }
  data = {
    "values.yaml" = <<EOF
alphaConfig:
  configData:
    providers:
      - id: zitadel
        clientID: ${zitadel_application_oidc.sonarqube_app.client_id}
        clientSecret: ${zitadel_application_oidc.sonarqube_app.client_secret}
        provider: oidc
        name: zitadel
        oidcConfig:
          issuerURL: https://login.weebo.fr
          groupsClaim: roles
          emailClaim: email
          userIDClaim: email
          audienceClaims:
            - aud
        scope: openid profile email offline_access name
    EOF

  }
}