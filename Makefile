test:
	docker build -f ./build-env/Dockerfile ./build-env

build-amd64:
	docker buildx bake --set=*.context=./istio-envoy -f ./istio-envoy/bake.hcl amd64 --push

build-arm64:
	docker buildx bake --set=*.context=./istio-envoy -f ./istio-envoy/bake.hcl arm64 --push

build-build-env:
	docker buildx bake --set=*.context=./build-env -f ./build-env/bake.hcl --push

debug:
	docker run -it -e=VERSION=1.6.1 querycapistio/istio-enovy-build-env:1.6.1