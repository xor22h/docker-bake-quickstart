group "default" {
  targets = ["multi-platform", "bin"]
}

target "multi-platform" {
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["myapp/backend:latest"]
  output = ["type=image"]
}

target "bin" {
  platforms = ["linux/amd64", "linux/arm64"]
  target = "bin"
  output = ["type=local,dest=./build"]
}