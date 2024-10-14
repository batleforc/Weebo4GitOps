# Weebo Git Ops 4

## Goal

Setting up a more secure and efficient kubernetes cluster with GitOps.

So, the goal is :

- Observability
  - Monitoring through Prometheus
  - Logging through Loki
  - Tracing through Tempo
  - Alerting through Alertmanager
  - Dashboards through Grafana
  - Manifest sanity through Popeye
  - Security through Falco ( CrowdSec who will act as a Fail2Ban)
- Networking
  - DNS through Bind9 (log has to be parsed by Loki)
  - Ingress through the choosen one (Traefik, HaProxy ?) (log has to be parsed by Loki)
  - A securized CNI/ServiceMesh with NO OPEN TRAFFIC BETWEEN NS (Istio, Cilium, Calico ?)
  - A VPN to have a secure access to the cluster and the network
- A "perfect" dev env
  - Eclipse Che
  - Tekton
  - Backstage
  - Gitea
  - ArgoRollouts
  - and more
- Immutabilify, repeatability
  - ArgoCD for GitOps
  - Ansible for the setup and most of the configuration
  - Terraform for the remaining configuration

A part of the research can be found in [my folio](https://beta.maxleriche.net/doc/Project/kube-weebo/ressource)
