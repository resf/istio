# Deploy

# Istio Operator (by helm)

```
helm repo add querycapistio https://querycap.github.io/istio
helm install -n istio-operater querycapistio/istio-operator 
```

# Istio System

```
kubectl apply -k ./istio-system
```