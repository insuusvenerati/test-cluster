# Test Cluster Documentation

### Folders

Top level folders in this repo

- [apps](#apps)
- [clusters](#clusters)
- [infra](#infra)
- [secrets](#secrets)

---

## apps

This folder is for apps, microservices, and databases that are deployed to the cluster.

## clusters

### flux-system

This folder is for cluster configuration. This folder is bootstrapped by Flux and contains the core manifests to deploy
all the Flux components. *Do not directly modify these files.* Read more about bootstrapping a cluster with Flux.

### image-automation

This folder contains configuration for the image-automation service. See
the [image-automation docs](https://fluxcd.io/docs/guides/image-update/) for more information.

### kustomizations

This folder contains the kustomizations that flux will deploy to the cluster. For example:

##### clusters/home-lab/kustomizations/apps.yaml

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 24h0m0s
  path: ./apps
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  dependsOn:
    - name: istio-gateway
    - name: sops-secrets
```

This file will apply the `apps/` folder to the cluster.

### sources

This folder contains GitRepository and HelmRepository source configurations used to retrieve manifests and helm charts.
See [manage helm releases](https://fluxcd.io/docs/guides/helmreleases/#helm-repository) for more information.

## infra

This folder contains the infrastructure manifests that are deployed to the cluster. i.e. Istio, Kiali, Prometheus