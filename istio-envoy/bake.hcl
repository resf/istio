variable VERSION {
  default = "1.6.1"
}

target "arm64" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "querycapistio/istio-enovy:${VERSION}-arm64"
  ]
  args = {
    VERSION = "${VERSION}"
  }
  platforms = [
    "linux/arm64"
  ]
}

target "amd64" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "querycapistio/istio-enovy:${VERSION}-amd64"
  ]
  args = {
    VERSION = "${VERSION}"
  }
  platforms = [
    "linux/amd64"
  ]
}