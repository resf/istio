# Deploy Guide

0. make sure aarch64 (32bit is not supported. because of the envoy, with needs google wee8)

1. install Istio Operator (by helm)

```
helm repo add querycapistio https://querycap.github.io/istio
helm install -n istio-operator querycapistio/istio-operator 
```

2. create a IstioOperator spec file and deploy it by kubectl, with
   * [affinity overwrites](https://github.com/querycap/istio/blob/master/deploy/istio-system/istio-operator.yaml#L11) for each component 
   * `spec.hub: docker.io/querycapistio`
