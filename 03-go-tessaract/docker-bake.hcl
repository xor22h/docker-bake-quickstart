group "default" {
  targets = ["binaries", "images"]
}

variable "flavors" {
  default = [
    {os_family = "ubuntu", os_version = "noble", packages = "wget ca-certificates build-essential pkg-config libtesseract-dev", runtime_packages = "libtesseract5"},
    {os_family = "debian", os_version = "bookworm", packages = "wget ca-certificates build-essential pkg-config libtesseract-dev", runtime_packages = "libtesseract5"},
    {os_family = "debian", os_version = "bullseye", packages = "wget ca-certificates build-essential pkg-config libtesseract-dev", runtime_packages = "libtesseract4"},
    {os_family = "rockylinux", os_version = "9", packages = "wget gcc g++ pkgconfig tesseract-devel", runtime_packages = "tesseract"},
    {os_family = "alpine", os_version = "latest", packages = "wget build-base pkgconf tesseract-ocr-dev", runtime_packages = "tesseract-ocr"},
  ]
}

target "base" {
  dockerfile = "Dockerfile"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}

target "binaries" {
  inherits = ["base"]
  
  matrix = {
    item = flavors
  }

  args = {
    OS_FAMILY = item.os_family,
    OS_VERSION = item.os_version,
    PACKAGES = item.packages,
    RUNTIME_PACKAGES = item.runtime_packages,
    GO_VERSION = "1.23.5",
  }

  name = "bin-${item.os_family}-${item.os_version}"
  description = "Build binary for ${item.os_family}/${item.os_version}"
  target = "bin"

  output = [
    "type=local,dest=./artifacts/${item.os_family}-${item.os_version}",
  ]
}

target "images" {
  inherits = ["base"]
  
  matrix = {
    item = flavors
  }

  args = {
    OS_FAMILY = item.os_family,
    OS_VERSION = item.os_version,
    PACKAGES = item.packages,
    RUNTIME_PACKAGES = item.runtime_packages,
    GO_VERSION = "1.23.5",
  }

  name = "image-${item.os_family}-${item.os_version}"
  description = "Build image for ${item.os_family}/${item.os_version}"
  tags = ["ghcr.io/xor22h/docker-bake-quickstart/app:${item.os_family}-${item.os_version}"]
}

