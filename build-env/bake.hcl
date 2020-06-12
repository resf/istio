variable VERSION {
  default = "1.6.1"
}

target "arm64" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "querycapistio/build-env:${VERSION}-arm64"
  ]
  platforms = [
    "linux/arm64"
  ]
}

target "amd64" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "querycapistio/build-env:${VERSION}-amd64"
  ]
  platforms = [
    "linux/amd64"
  ]
}
