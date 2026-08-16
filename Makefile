.PHONY: dev frontend backend build-frontend build-backend format test-backend test-frontend \
	clean clean-frontend clean-backend \
	docker-build docker-build-backend docker-build-frontend \
	docker-run-backend docker-run-frontend

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

# Build both Docker images
docker-build: docker-build-backend docker-build-frontend

# Build backend Docker image (build context = repo root, go.work spans modules)
docker-build-backend:
	docker build -f infra/docker/backend.Dockerfile -t theseus-backend .

# Build frontend Docker image (build context = apps/frontend)
docker-build-frontend:
	docker build -f infra/docker/frontend.Dockerfile -t theseus-frontend apps/frontend

# Run backend container (http://localhost:8080)
docker-run-backend:
	docker run --rm -p 8080:8080 theseus-backend

# Run frontend container (http://localhost:8081)
docker-run-frontend:
	docker run --rm -p 8081:80 theseus-frontend

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