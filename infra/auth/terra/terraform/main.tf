terraform {
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = "2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.33.0"
    }
  }
}

variable "path" {
  type    = string
  default = "/machine-key"
}

variable "kubepath" {
  type    = string
  default = "/var/run/secrets/kubernetes.io/serviceaccount"
}

variable "domain" {
  type    = string
  default = "login.weebo.fr"
}

provider "kubernetes" {
  host                   = "https://kubernetes.default.svc"
  token                  = file("${var.kubepath}/token")
  cluster_ca_certificate = file("${var.kubepath}/ca.crt")
}

provider "zitadel" {
  domain           = var.domain
  jwt_profile_file = "${var.path}/zitadel-admin-sa.json"
  port             = 443
}

resource "zitadel_org" "weebo" {
  name = "weebo"
}

resource "zitadel_action" "role_mapper" {
  org_id          = zitadel_org.weebo.id
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

resource "zitadel_trigger_actions" "role_mapper_trigger_userinfo" {
  org_id       = zitadel_org.weebo.id
  action_ids   = [zitadel_action.role_mapper.id]
  flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
  trigger_type = "TRIGGER_TYPE_PRE_USERINFO_CREATION"
}

resource "zitadel_trigger_actions" "role_mapper_trigger_creation" {
  org_id       = zitadel_org.weebo.id
  action_ids   = [zitadel_action.role_mapper.id]
  flow_type    = "FLOW_TYPE_CUSTOMISE_TOKEN"
  trigger_type = "TRIGGER_TYPE_PRE_ACCESS_TOKEN_CREATION"
}

# resource "zitadel_smtp_config" "default" {
#   sender_address = "zitadel@weebo.fr"
#   sender_name    = "no-reply-zitadel"
#   host           = "mailcatcher.mailcatcher.svc.cluster.local:1025"
# }
