# syntax=docker/dockerfile:1

# Build context must be the repository root (go.work spans apps/backend + packages/go-lib):
#   docker build -f infra/docker/backend.Dockerfile -t theseus-backend .

FROM golang:1.26-alpine AS build

WORKDIR /src

# Copy workspace + module files first for dependency layer caching
COPY go.work ./
COPY apps/backend/go.mod apps/backend/go.sum* ./apps/backend/
COPY packages/go-lib/go.mod packages/go-lib/go.sum* ./packages/go-lib/

RUN cd apps/backend && go mod download

# Copy source
COPY apps/backend ./apps/backend
COPY packages/go-lib ./packages/go-lib

# Build a static binary
RUN CGO_ENABLED=0 GOOS=linux go build -C apps/backend \
      -ldflags="-s -w" -trimpath \
      -o /out/api ./cmd/api

FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=build /out/api /api

EXPOSE 8080

ENTRYPOINT ["/api"]
