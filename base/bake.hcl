variable VERSION {
  default = "1.6.1"
}

variable HUB {
  default = "istio"
}

target "default" {
  dockerfile = "base.Dockerfile"
  tags = [
    "${HUB}/base:${VERSION}"
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}