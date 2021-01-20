BINARY=goapp
run:
	go run main.go

install:
	go mod download && go mod tidy

test: 
	go test -v -cover -covermode=atomic ./...

build:
	go build -o build/${BINARY} main.go

unittest:
	go test -short  ./...

clean:
	if [ -f build/${BINARY} ] ; then rm -rf build ; fi

docker:
	docker build -t go-service .

lint-prepare:
	@echo "Installing golangci-lint" 
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s latest

lint:
	./bin/golangci-lint run ./...

.PHONY: clean install unittest build docker lint-prepare lint
