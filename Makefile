HUB=ghcr.io/querycap/istio docker.io/querycapistio

gen: install
	HUB="$(HUB)" go run github.com/querycap/ci-infra/cmd/imagetools

install:
	go get github.com/querycap/ci-infra/cmd/imagetools@master

sync: sync.istio-operator sync.jaeger-operator

sync.istio-operator:
	bash ./tools/sync-istio-operator.sh

sync.jaeger-operator:
	bash ./tools/sync-jaeger-operator.sh