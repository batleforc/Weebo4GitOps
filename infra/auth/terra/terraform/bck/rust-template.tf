resource "zitadel_org" "template" {
  name = "template"
}

resource "zitadel_action" "role_mapper_template" {
  org_id          = zitadel_org.template.id
  name            = "role_mapper"
  timeout         = "20s"
  allowed_to_fail = true
  script          = <<EOF
    function role_mapper(ctx, api){
      let role = [];
      let claimKey = "roles";
      let roles = ctx.v1.claims["urn:zitadel:iam:org:project:roles"];
      Object.keys(roles).forEach((key)=>{
          role.push(key)
      })
      api.v1.claims.setClaim(claimKey,role);
      api.v1.claims.setClaim(ctx.v1.claims["client_id"].split("@")[1],role);
    }
    EOF
}

resource "zitadel_trigger_actions" "role_mapper_trigger_userinfo_template" {
  org_id       = zitadel_org.template.id
  action_ids   = [zitadel_action.role_mapper_template.id]
  flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
  trigger_type = "TRIGGER_TYPE_PRE_USERINFO_CREATION"
}

resource "zitadel_trigger_actions" "role_mapper_trigger_creation_template" {
  org_id       = zitadel_org.template.id
  action_ids   = [zitadel_action.role_mapper_template.id]
  flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
  trigger_type = "TRIGGER_TYPE_PRE_ACCESS_TOKEN_CREATION"
}

resource "zitadel_human_user" "batleforc_dev" {
  org_id             = zitadel_org.template.id
  user_name          = "batleforc@localhost.com"
  first_name         = "max"
  last_name          = "batleforc"
  nick_name          = "batleforc"
  display_name       = "Maxime"
  preferred_language = "en"
  gender             = "GENDER_MALE"
  email              = "max@weebo.fr"
  is_email_verified  = true
  initial_password   = "Rust_template1"
}


resource "zitadel_org_member" "batleforc_dev_org" {
  org_id  = zitadel_org.template.id
  user_id = zitadel_human_user.batleforc_dev.id
  roles   = ["ORG_OWNER"]
}


resource "zitadel_project" "rust_template" {
  org_id                 = zitadel_org.template.id
  name                   = "rust_template"
  project_role_assertion = true
}

resource "zitadel_project_role" "admin" {
  org_id       = zitadel_org.template.id
  project_id   = zitadel_project.rust_template.id
  role_key     = "ADMIN"
  display_name = "Admin"
  group        = "ADMIN"
}

resource "zitadel_project_role" "moderator" {
  org_id       = zitadel_org.template.id
  project_id   = zitadel_project.rust_template.id
  role_key     = "MODERATOR"
  display_name = "Moderator"
  group        = "MODERATOR"
}
resource "zitadel_project_role" "member" {
  org_id       = zitadel_org.template.id
  project_id   = zitadel_project.rust_template.id
  role_key     = "MEMBER"
  display_name = "Member"
  group        = "MEMBER"
}

resource "zitadel_user_grant" "batleforc_template" {
  project_id = zitadel_project.rust_template.id
  org_id     = zitadel_org.template.id
  role_keys  = ["ADMIN"]
  user_id    = zitadel_human_user.batleforc_dev.id
}

resource "zitadel_application_api" "backend_template" {
  org_id           = zitadel_org.template.id
  project_id       = zitadel_project.rust_template.id
  name             = "backend"
  auth_method_type = "API_AUTH_METHOD_TYPE_PRIVATE_KEY_JWT"
}
resource "zitadel_application_key" "backend_key_template" {
  org_id          = zitadel_org.template.id
  project_id      = zitadel_project.rust_template.id
  app_id          = zitadel_application_api.backend_template.id
  key_type        = "KEY_TYPE_JSON"
  expiration_date = "2500-12-31T23:59:59Z"
}

resource "zitadel_application_oidc" "frontend_template" {
  project_id                  = zitadel_project.rust_template.id
  org_id                      = zitadel_org.template.id
  name                        = "frontend"
  redirect_uris               = ["https://template.weebo.fr/oauth2/callback", "https://oauth.pstmn.io/v1/callback", "http://localhost:5437/oauth2/callback", "http://localhost:5173/oauth2/callback", "https://bu-teammaker.weebo.fr/oauth2/callback", "https://main-bu-teammaker.dev.weebo.fr/oauth2/callback"]
  response_types              = ["OIDC_RESPONSE_TYPE_CODE"]
  grant_types                 = ["OIDC_GRANT_TYPE_AUTHORIZATION_CODE"]
  post_logout_redirect_uris   = ["https://template.weebo.fr/api/oauth2/logout"]
  app_type                    = "OIDC_APP_TYPE_WEB"
  auth_method_type            = "OIDC_AUTH_METHOD_TYPE_NONE"
  access_token_type           = "OIDC_TOKEN_TYPE_BEARER"
  access_token_role_assertion = true
  id_token_role_assertion     = true
  id_token_userinfo_assertion = true
  dev_mode                    = true
  additional_origins          = ["https://template.weebo.fr", "https://oauth.pstmn.io", "http://localhost:5437", "https://bu-teammaker.weebo.fr", "http://localhost:5173", "https://main-bu-teammaker.dev.weebo.fr"]
}

resource "kubernetes_secret_v1" "frontend_template" {
  metadata {
    name      = "frontend-auth"
    namespace = "template-rust"
  }
  data = {
    client_id = zitadel_application_oidc.frontend_template.client_id
  }
}

resource "kubernetes_secret_v1" "backend_template" {
  metadata {
    name      = "backend-auth"
    namespace = "template-rust"
  }
  data = yamldecode(zitadel_application_key.backend_key_template.key_details)
}


resource "kubernetes_secret_v1" "frontend_bu_teammaker" {
  metadata {
    name      = "frontend-auth"
    namespace = "bu-teammaker"
  }
  data = {
    client_id = zitadel_application_oidc.frontend_template.client_id
  }
}
resource "kubernetes_secret_v1" "backend_bu_teammaker" {
  metadata {
    name      = "backend-auth"
    namespace = "bu-teammaker"
  }
  data = yamldecode(zitadel_application_key.backend_key_template.key_details)
}
