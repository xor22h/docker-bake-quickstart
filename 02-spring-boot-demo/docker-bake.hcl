variable "SONAR_TOKEN" {}
group "default" {
  targets = ["build", "tests"]
}

target "build" {
  dockerfile = "Dockerfile"
  target = "application"
  tags = ["spring-app:latest"]
}

target "tests" {
  dockerfile = "Dockerfile"
  target = "test-results"
  output = ["type=local,dest=./test-results"]
}

target "sonar" {
  dockerfile = "Dockerfile"
  target = "sonar-results"
  output = ["type=local,dest=./sonar-reports"]
  args = {
    SONAR_TOKEN = "${SONAR_TOKEN}"
    SONAR_PROJECT_KEY = "my-spring-app"
    SONAR_SERVER = "https://sonarqube.example.com" # http://localhost:9000
  }
  depends_on = ["tests"]
}
