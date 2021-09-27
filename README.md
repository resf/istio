# Istio OCI Images (`linux/arm64, linux/amd64`)

This repo is for building oci images for istio stacks
(until [official supports](https://github.com/istio/istio/issues/26652#issuecomment-872702369)).

## How to use?

using images under `docker.io/querycapistio`

### Environment Requirements

make sure aarch64 (32bit is not supported. because of the envoy, with needs google wee8)

### Install Istio Operator

Same as https://istio.io/latest/docs/setup/install/operator, but with `--hub`

```
$ istioctl operator init --hub=docker.io/querycapistio --tag=1.9.2
```

### Install with Istioctl

Same as https://istio.io/latest/docs/setup/install/istioctl/

Create a custom manifest file (sample name my-arm64-config.yaml) with below contents:

```
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane
spec:
  hub: docker.io/querycapistio
  profile: demo
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
      - name: "istio-egressgateway"
        k8s:
          affinity: *affinity
    ingressGateways:
      - name: "istio-ingressgateway"
        k8s:
          affinity: *affinity
```

Create the Istio resources

```
$ istioctl install -f my-arm64-config.yaml
This will install the Istio 1.11.2 demo profile with ["Istio core" "Istiod" "Ingress gateways" "Egress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed
✔ Istiod installed
✔ Egress gateways installed
✔ Ingress gateways installed
✔ Installation complete
Thank you for installing Istio 1.11.  Please take a few minutes to tell us about your install/upgrade experience!  https://forms.gle/kWULBRjUv7hHci7T6
```

Check resources & images deployed

```
$ kubectl get po -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-67b877fd45-2s6ch    1/1     Running   0          7m15s
istio-ingressgateway-646f74957c-5cfwr   1/1     Running   0          7m15s
istiod-6fcb9b9f59-z2w8n                 1/1     Running   0          7m21s
$ kubectl get po istiod-6fcb9b9f59-z2w8n -n istio-system -o yaml | grep image
    image: docker.io/querycapistio/pilot:1.11.2
    imagePullPolicy: IfNotPresent
    image: querycapistio/pilot:1.11.2
    imageID: docker-pullable://querycapistio/pilot@sha256:ace99d1faaf269721be587efcad309a740d924a7a1ecf4847d966981a92760e4
$ kubectl get po istio-egressgateway-67b877fd45-2s6ch -n istio-system -o yaml | grep image
    image: docker.io/querycapistio/proxyv2:1.11.2
    imagePullPolicy: IfNotPresent
    image: querycapistio/proxyv2:1.11.2
    imageID: docker-pullable://querycapistio/proxyv2@sha256:57223fb22b28b3864e07498d848e1f988b029ec0c6ea54f4504e11d11b450e33
$ kubectl get po istio-ingressgateway-646f74957c-5cfwr -n istio-system -o yaml | grep image
    image: docker.io/querycapistio/proxyv2:1.11.2
    imagePullPolicy: IfNotPresent
    image: querycapistio/proxyv2:1.11.2
    imageID: docker-pullable://querycapistio/proxyv2@sha256:57223fb22b28b3864e07498d848e1f988b029ec0c6ea54f4504e11d11b450e33
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

since
1.10.x, `values.global.arch` [deprecated](https://istio.io/latest/news/releases/1.10.x/announcing-1.10/change-notes/#deprecation-notices)
, we may not need this any more.

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
      - name: "istio-egressgateway"
        k8s:
          affinity: *affinity
    ingressGateways:
      - name: "istio-ingressgateway"
        k8s:
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


## `querycapistio/install-cni:{VERSION}[-distroless]`

[![Docker Version](https://img.shields.io/docker/v/querycapistio/install-cni?sort=semver)](https://hub.docker.com/r/querycapistio/install-cni/tags)
![Docker Image Size](https://img.shields.io/docker/image-size/querycapistio/install-cni?sort=semver)
![Docker Pulls](https://img.shields.io/docker/pulls/querycapistio/install-cni)

# Notice

* *all images tag version without `v` prefix* like official did
