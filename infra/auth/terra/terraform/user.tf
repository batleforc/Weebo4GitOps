resource "zitadel_human_user" "batleforc" {
  org_id             = zitadel_org.weebo.id
  user_name          = "batleforc@login.weebo.fr"
  first_name         = "Maxime"
  last_name          = "Leriche"
  nick_name          = "batleforc"
  display_name       = "Max"
  preferred_language = "en"
  gender             = "GENDER_MALE"
  email              = "maxleriche.60@gmail.com"
  is_email_verified  = true
  initial_password   = "NTpxcOT0BPIuG3j3zwh?"
}

resource "zitadel_org_member" "batleforc_org" {
  org_id  = zitadel_org.weebo.id
  user_id = zitadel_human_user.batleforc.id
  roles   = ["ORG_OWNER"]
}

resource "zitadel_instance_member" "batleforc_instance" {
  user_id = zitadel_human_user.batleforc.id
  roles   = ["IAM_OWNER"]
}

resource "zitadel_user_grant" "batleforc_grafana" {
  project_id = zitadel_project.grafana.id
  org_id     = zitadel_org.weebo.id
  role_keys  = [zitadel_project_role.grafana_admin.role_key]
  user_id    = zitadel_human_user.batleforc.id
}

# resource "zitadel_user_grant" "batleforc_tekton" {
#   project_id = zitadel_project.tekton.id
#   org_id     = zitadel_org.weebo.id
#   role_keys  = [zitadel_project_role.tekton_admin.role_key]
#   user_id    = zitadel_human_user.batleforc.id
# }

# resource "zitadel_user_grant" "batleforc_gitea" {
#   project_id = zitadel_project.gitea.id
#   org_id     = zitadel_org.weebo.id
#   role_keys  = [zitadel_project_role.gitea_admin.role_key]
#   user_id    = zitadel_human_user.batleforc.id
# }

resource "zitadel_user_grant" "batleforc_harbor" {
  project_id = zitadel_project.harbor.id
  org_id     = zitadel_org.weebo.id
  role_keys  = [zitadel_project_role.harbor_admin.role_key]
  user_id    = zitadel_human_user.batleforc.id
}

# resource "zitadel_user_grant" "batleforc_sonarqube" {
#   project_id = zitadel_project.sonarqube.id
#   org_id     = zitadel_org.weebo.id
#   role_keys  = [zitadel_project_role.sonarqube_admin.role_key]
#   user_id    = zitadel_human_user.batleforc.id
# }

resource "zitadel_user_grant" "batleforc_cluster" {
  project_id = zitadel_project.cluster.id
  org_id     = zitadel_org.weebo.id
  role_keys  = [zitadel_project_role.cluster_admin.role_key]
  user_id    = zitadel_human_user.batleforc.id
}

# resource "zitadel_user_grant" "batleforc_longhorn" {
#   project_id = zitadel_project.longhorn.id
#   org_id     = zitadel_org.weebo.id
#   role_keys  = [zitadel_project_role.longhorn_admin.role_key]
#   user_id    = zitadel_human_user.batleforc.id
# }
# resource "zitadel_user_grant" "batleforc_grocy" {
#   project_id = zitadel_project.grocy.id
#   org_id     = zitadel_org.weebo.id
#   role_keys  = [zitadel_project_role.grocy_admin.role_key]
#   user_id    = zitadel_human_user.batleforc.id
# }
