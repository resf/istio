target "arm64" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "querycapistio/hsdis:latest-arm64"
  ]
  platforms = [
    "linux/arm64"
  ]
}

target "amd64" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "querycapistio/hsdis:latest-amd64"
  ]
  platforms = [
    "linux/amd64"
  ]
}
