FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY . .
# If go.mod doesn't exist yet, we initialize a temp one to build the simple main.go
# This allows the Docker build to succeed before the full app is written.
RUN [ -f go.mod ] || go mod init poc-app
RUN go build -o main .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/main .
RUN apk add --no-cache curl iproute2
CMD ["./main"]
