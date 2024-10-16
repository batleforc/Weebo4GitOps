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

## Research

A part of the research can be found in [my folio](https://beta.maxleriche.net/doc/Project/kube-weebo/ressource)

## Engine

ATM, the engine was K3s, but i need to consider the other options has weebo4 is meant to have more than one node.

- [K3s](https://k3s.io/)
- [Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)
- [Kubespray](https://kubespray.io/)
- [RKE](https://rancher.com/docs/rke/latest/en/)

<https://medium.com/@ferdinandklr/creating-a-production-ready-self-hosted-kubernetes-cluster-from-scratch-on-a-vps-ipv6-compatible-660aa5018feb>
<https://blog.zwindler.fr/2023/09/15/k3s-ajouter-monitoring>
<https://www.scaleway.com/en/docs/tutorials/deploy-k3s-cluster-with-cilium>
<https://www.armand.nz/notes/k3s/Install%20K3s%20with%20Cilium%20single-node%20cluster%20on%20Debian>
<https://rpi4cluster.com/k3s-monitoring-install-grafana>
