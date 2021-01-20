# build
FROM golang:1.14-alpine as builder

RUN apk update && apk add tzdata librdkafka-dev gcc g++ make pkgconf \
    && cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime \
    && echo "Asia/Bangkok" >  /etc/timezone \
    && apk del tzdata

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN go clean --cache

RUN go build -o goapp main.go

# ---------------------------------------------------------

# run
FROM alpine:latest

RUN apk update && apk add tzdata \
    && cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime \
    && echo "Asia/Bangkok" >  /etc/timezone \
    && apk del tzdata

WORKDIR /app

COPY --from=builder /app/goapp .
COPY --from=builder /app/config.json .

CMD ["./goapp"]
