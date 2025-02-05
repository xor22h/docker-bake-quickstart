# syntax=docker/dockerfile:1

ARG OS_FAMILY=debian
ARG OS_VERSION=bullseye

FROM ${OS_FAMILY}:${OS_VERSION} AS builder
ARG OS_FAMILY
ARG OS_VERSION
ARG PACKAGES

# OS-specific package installation
RUN if [ "${OS_FAMILY}" = "debian" ] || [ "${OS_FAMILY}" = "ubuntu" ]; then \
        apt-get update && apt-get install --no-install-recommends -y ${PACKAGES} \
        ; \
    elif [ "${OS_FAMILY}" = "alpine" ]; then \
        apk add --no-cache ${PACKAGES}; \
    elif [ "${OS_FAMILY}" = "rockylinux" ]; then \
        yum install -y epel-release; crb enable; \
        yum install -y ${PACKAGES}; \
    fi

# Set Go version
ARG GO_VERSION=1.23.5

# Determine architecture
ARG TARGETARCH
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-${TARGETARCH}.tar.gz && \
    rm go${GO_VERSION}.linux-${TARGETARCH}.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Verify installation
RUN go version

WORKDIR /app
COPY . .
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -ldflags="-s -w" -o myapp .

FROM scratch AS bin
COPY --from=builder /app/myapp /

FROM ${OS_FAMILY}:${OS_VERSION} AS runtime
ARG OS_FAMILY
ARG OS_VERSION
ARG RUNTIME_PACKAGES

RUN if [ "${OS_FAMILY}" = "debian" ] || [ "${OS_FAMILY}" = "ubuntu" ]; then \
        apt-get update && apt-get install --no-install-recommends -y ${RUNTIME_PACKAGES} \
        ; \
    elif [ "${OS_FAMILY}" = "alpine" ]; then \
        apk add --no-cache ${RUNTIME_PACKAGES}; \
    elif [ "${OS_FAMILY}" = "rockylinux" ]; then \
        yum install -y ${RUNTIME_PACKAGES}; \
    fi


COPY --from=builder /app/myapp /usr/bin/mypp
