gen:
	go get github.com/querycap/ci-infra/cmd/imagetools@master
	HUB=querycapistio go run github.com/querycap/ci-infra/cmd/imagetools
