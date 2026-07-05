.PHONY: build clean test run help

# Build the application
build:
	@echo "Building Bnk..."
	@mkdir -p bin
	@go build -o bin/bnk ./cmd/main.go

# Build for all platforms
build-all:
	@echo "Building for all platforms..."
	@mkdir -p dist
	@GOOS=linux GOARCH=amd64 go build -o dist/bnk-linux-amd64 ./cmd/main.go
	@GOOS=linux GOARCH=arm64 go build -o dist/bnk-linux-arm64 ./cmd/main.go
	@GOOS=darwin GOARCH=amd64 go build -o dist/bnk-darwin-amd64 ./cmd/main.go
	@GOOS=darwin GOARCH=arm64 go build -o dist/bnk-darwin-arm64 ./cmd/main.go
	@GOOS=windows GOARCH=amd64 go build -o dist/bnk-windows-amd64.exe ./cmd/main.go

# Run the application
run: build
	@./bin/bnk -config example-config.yaml

# Clean build artifacts
clean:
	@echo "Cleaning..."
	@rm -rf bin/ dist/

# Run tests
test:
	@echo "Running tests..."
	@go test -v ./...

# Show help
help:
	@echo "Available targets:"
	@echo "  make build       - Build the application"
	@echo "  make build-all   - Build for all platforms"
	@echo "  make run         - Build and run the application"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make test        - Run tests"
	@echo "  make help        - Show this help message"
