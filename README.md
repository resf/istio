# Istio OCI Images (`linux/arm64, linux/amd64`)

This repo is for building oci images for istio stacks.

## How to use?

using images under `docker.io/querycapistio`

### Environment Requirements

make sure aarch64 (32bit is not supported. because of the envoy, with needs google wee8)

### Install Istio Operator

Same as https://istio.io/latest/docs/setup/install/operator, but with `--hub`

```
$ istioctl operator init --hub=docker.io/querycapistio --tag=1.9.2
```

### Install Istio

Same as https://istio.io/latest/docs/setup/install

```
$ kubectl create ns istio-system
$ kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane
spec:
  hub: docker.io/querycapistio
  profile: demo
EOF
```

notice the `spec.hub`, if deploy failed on arm64 hosts. should set `spec.components.*.k8s.affinity`, like

```yaml
spec:
  components:
    pilot:
      k8s: # each components have to set this
        affinity: &affinity
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
                - matchExpressions:
                    - key: kubernetes.io/arch
                      operator: In
                      values:
                        - arm64
                        - amd64
    egressGateways:
      - k8s:
          affinity: *affinity
    ingressGateways:
      - k8s:
          affinity: *affinity
```

## [`Istio Components`](https://github.com/istio/istio)

## `querycapistio/proxyv2:{VERSION}[-distroless]`

[![Docker Version](https://img.shields.io/docker/v/querycapistio/proxyv2?sort=semver)](https://hub.docker.com/r/querycapistio/proxyv2/tags)
![Docker Image Size](https://img.shields.io/docker/image-size/querycapistio/proxyv2?sort=semver)
![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/proxyv2)

## `querycapistio/pilot:{VERSION}[-distroless]`

[![Docker Version](https://img.shields.io/docker/v/querycapistio/pilot?sort=semver)](https://hub.docker.com/r/querycapistio/pilot/tags)
![Docker Image Size](https://img.shields.io/docker/image-size/querycapistio/pilot?sort=semver)
![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/pilot)

## `querycapistio/operator:{VERSION}[-distroless]`

[![Docker Version](https://img.shields.io/docker/v/querycapistio/operator?sort=semver)](https://hub.docker.com/r/querycapistio/operator/tags)
![Docker Image Size](https://img.shields.io/docker/image-size/querycapistio/operator?sort=semver)
![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/operator)

## `querycapistio/istio-envoy:{VERSION}`

[![Docker Version](https://img.shields.io/docker/v/querycapistio/istio-envoy?sort=semver)](https://hub.docker.com/r/querycapistio/istio-envoy/tags)
![Docker Image Size](https://img.shields.io/docker/image-size/querycapistio/istio-envoy?sort=semver)
![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/istio-envoy)

# Notice

* *all images tag version without `v` prefix* like official did