# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM golang:alpine AS build

ARG TARGETOS
ARG TARGETARCH

WORKDIR /app
COPY . .

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o server .

FROM scratch AS bin
COPY --from=build /app/server /server

FROM alpine
COPY --from=build /app/server /server

ENTRYPOINT ["/server"]

