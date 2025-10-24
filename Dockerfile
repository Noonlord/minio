FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git make

WORKDIR /build

COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -trimpath -tags kqueue -o minio .

FROM alpine:latest

RUN apk add --no-cache ca-certificates

RUN addgroup -g 1000 minio && \
    adduser -D -u 1000 -G minio minio

COPY --from=builder /build/minio /usr/bin/minio
COPY dockerscripts/docker-entrypoint.sh /usr/bin/docker-entrypoint.sh
RUN chmod +x /usr/bin/minio /usr/bin/docker-entrypoint.sh

RUN mkdir -p /data && chown minio:minio /data

USER minio

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

VOLUME ["/data"]

EXPOSE 9000 9001

CMD ["minio"]
