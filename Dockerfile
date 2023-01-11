FROM golang:1.17.0-alpine AS builder
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
ENTRYPOINT [ "/httpx", "-silent", "-json", "-no-fallback", "-pipeline", "-response-in-json", "-tech-detect", "-output", "/output" ]