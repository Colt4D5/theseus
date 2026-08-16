# Run frontend and backend concurrently
dev:
	pnpm --filter frontend dev &
	cd apps/backend && go run cmd/api/main.go

# Run frontend only
frontend:
	pnpm --filter frontend dev

# Run backend only
backend:
	cd apps/backend && go run cmd/api/main.go

# Build frontend for production
build-frontend:
	cd apps/frontend && pnpm build

# Build backend for production
build-backend:
	cd apps/backend && go build -o theseus-api ./cmd/api

# Format Go + TypeScript
format:
	pnpm --filter frontend format
	cd apps/backend && go fmt ./...
	cd packages/go-lib && go fmt ./...

# Run Go tests
test-backend:
	cd apps/backend && go test ./...

# Run TypeScript tests
test-frontend:
	pnpm --filter frontend test

# Clean build artifacts
clean:
	rm -rf apps/frontend/dist
	rm -rf apps/backend/theseus-api

# Clean frontend build artifacts
clean-frontend:
	rm -rf apps/frontend/dist

# Clean backend build artifacts
clean-backend:
	rm -rf apps/backend/theseus-api