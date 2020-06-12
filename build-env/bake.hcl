variable VERSION {
  default = "1.6.1"
}

target "default" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "querycapistio/istio-enovy-build-env:${VERSION}"
  ]
  args = {
    VERSION = "${VERSION}"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
