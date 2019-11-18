# Build layer
FROM golang:1.13 AS builder
WORKDIR /go/src/github.com/seatgeek/mysql-checker
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o build/mysql-checker  .

# Run layer
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/seatgeek/mysql-checker/build/mysql-checker .
CMD ["./mysql-checker"]
