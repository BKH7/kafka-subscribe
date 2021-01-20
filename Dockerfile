# build
# FROM golang:1.15-alpine as builder
FROM golang:1.15

# RUN apk update && apk add tzdata librdkafka-dev pkgconf build-base \
#     && cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime \
#     && echo "Asia/Bangkok" >  /etc/timezone \
#     && apk del tzdata

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN go clean --cache

# RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o goapp main.go
RUN go build -o goapp main.go
CMD ["./goapp"]

# ---------------------------------------------------------

# run
# FROM alpine:latest

# RUN apk update && apk add tzdata \
#     && cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime \
#     && echo "Asia/Bangkok" >  /etc/timezone \
#     && apk del tzdata

# WORKDIR /app

# COPY --from=builder /app/goapp .
# COPY --from=builder /app/config.json .

# CMD ["./goapp"]
