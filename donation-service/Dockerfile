# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Instala dependências necessárias no Alpine
RUN apk update && apk add --no-cache git ca-certificates tzdata

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Compila o binário estaticamente (essencial para rodar no scratch)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/bin/server main.go

# Stage 2: Runtime
FROM scratch

# Copia os certificados e tzdata do builder (essencial para AWS HTTPS requests)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

WORKDIR /app

COPY --from=builder /app/bin/server /app/server

EXPOSE 8082

CMD ["/app/server"]
