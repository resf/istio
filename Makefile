HUB=ghcr.io/querycap/istio docker.io/querycapistio

gen: install
	HUB="$(HUB)" go run github.com/querycap/ci-infra/cmd/imagetools

install:
	go get github.com/querycap/ci-infra/cmd/imagetools@master

word-dot = $(word $2,$(subst ., ,$1))

dockerx.%:
	$(MAKE) -C build/$(call word-dot,$*,1) dockerx HUB="$(HUB)" DOCKERX_NAME=$(call word-dot,$*,2)

imagetools.%:
	$(MAKE) -C build/$(call word-dot,$*,1) imagetools HUB="$(HUB)" DOCKERX_NAME=$(call word-dot,$*,2)

sync: sync.istio-operator

sync.istio-operator:
	bash ./tools/sync-istio-operator.sh