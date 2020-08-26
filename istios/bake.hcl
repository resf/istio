variable VERSION {
  default = "1.6.3"
}

variable ENVOY_VERSION {
  default = ""
}

variable HUB {
  default = "istio"
}

variable BASE_VERSION {
  default = "2020-07-10"
}

group "default" {
  targets = [
    "proxyv2",
    "pilot",
    "operator"
  ]
}

target "proxyv2" {
  dockerfile = "proxyv2.Dockerfile"
  tags = [
    "${HUB}/proxyv2:${VERSION}"
  ]
  args = {
    BASE_DISTRIBUTION = "${HUB}/base:${BASE_VERSION}"
    VERSION = "${VERSION}"
    ENVOY_VERSION = "${ENVOY_VERSION}"
  }
  platforms = [
    "linux/arm64",
    "linux/amd64"
  ]
}

target "pilot" {
  dockerfile = "pilot.Dockerfile"
  tags = [
    "${HUB}/pilot:${VERSION}"
  ]
  args = {
    BASE_DISTRIBUTION = "${HUB}/base:${BASE_VERSION}"
    VERSION = "${VERSION}"
  }
  platforms = [
    "linux/arm64",
    "linux/amd64"
  ]
}
target "operator" {
  dockerfile = "operator.Dockerfile"
  tags = [
    "${HUB}/operator:${VERSION}"
  ]
  args = {
    BASE_DISTRIBUTION = "${HUB}/base:${BASE_VERSION}"
    VERSION = "${VERSION}"
  }
  platforms = [
    "linux/arm64",
    "linux/amd64"
  ]
}