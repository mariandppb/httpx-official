FROM golang:1.19.4-alpine AS builder
ARG BUILD_SOURCE_TAG=latest
RUN apk add --no-cache git build-base gcc musl-dev
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@${BUILD_SOURCE_TAG}

WORKDIR /go/src/httpx
ADD go.mod .
ADD go.sum .
RUN go mod download
ADD . .
RUN go build -v -ldflags="-s -w" -o "/httpx" cmd/httpx/httpx.go


FROM alpine:3.12

RUN apk add --no-cache bind-tools ca-certificates

COPY --from=builder /httpx /httpx

VOLUME /input
VOLUME /output

# any of these flags can be overriden with docker run args using "=false"
# example (disable pipeline probe): docker run httpx -pipeline=false
ENTRYPOINT [ "/httpx", "-silent", "-json", "-no-fallback", "-pipeline", "-tech-detect", "-output", "/output" ]

