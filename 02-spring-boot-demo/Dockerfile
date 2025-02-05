# syntax=docker/dockerfile:1

# Base build stage
FROM maven:3.8.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src/ ./src/

# Main application build target
FROM build AS application
RUN mvn clean package -DskipTests

# Test execution target
FROM build AS tests
RUN mvn test

# Gather test results in scratch image
FROM scratch AS test-results
COPY --from=tests /app/target/surefire-reports/ /

# SonarQube analysis target
FROM build AS sonar
ARG SONAR_TOKEN
ARG SONAR_PROJECT_KEY
ARG SONAR_SERVER
RUN mvn sonar:sonar \
    -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
    -Dsonar.host.url=${SONAR_SERVER} \
    -Dsonar.login=${SONAR_TOKEN}


FROM scratch AS sonar-results
COPY --from=sonar /app/target/sonar/ /
