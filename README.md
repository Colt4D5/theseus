# Theseus

**Theseus** is a full-stack writing application where humans compete against AI. Users write short stories based on a predefined set of prompts (words, objects, ideas, etc.). Each user story is then pitted against an AI-generated story written from the same prompt, and the community votes on which one they prefer. Authors receive a score showing the percentage of voters who preferred their story over the AI's, along with a variety of other metrics.

- **Frontend:** [SolidJS](https://www.solidjs.com/) + [Vite](https://vitejs.dev/) + TypeScript
- **Backend:** [Go](https://go.dev/) REST API
- **Monorepo:** pnpm workspaces (JS/TS) + Go workspaces (Go modules)

## Project Structure

```
theseus/
├── Makefile                  # Task runner for dev, build, test, format, clean
├── package.json              # Root pnpm workspace config
├── go.work                   # Go workspace config
├── apps/
│   ├── backend/              # Go API server (port :8080)
│   │   ├── cmd/api/          # API entrypoint (main.go)
│   │   └── internal/         # Domain packages
│   │       ├── matchups/     # Human vs. AI story matchups
│   │       ├── stories/      # Story creation & retrieval
│   │       ├── users/        # User accounts & profiles
│   │       └── votes/        # Voting on matchups
│   └── frontend/             # SolidJS app (Vite dev server)
│       └── src/
├── packages/
│   ├── go-lib/               # Shared Go utilities
│   └── types/                # Shared TypeScript types (Story, Matchup, Vote, ...)
├── infra/
│   └── docker/               # Dockerfiles for backend & frontend
└── scripts/                  # Utility scripts
```

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| [Go](https://go.dev/dl/) | 1.26+ | Matches `go.work` / `go.mod` |
| [Node.js](https://nodejs.org/) | 20+ (LTS recommended) | Required by Vite |
| [pnpm](https://pnpm.io/) | ^11.18.0 | Enforced via `devEngines`; auto-downloaded if missing/wrong version |
| GNU Make | any | Used for all common tasks |
| [Docker](https://www.docker.com/) | any recent | Optional — only needed for containerized builds/deployment |

To install pnpm:

```bash
corepack enable        # ships with Node.js
# or
npm install -g pnpm
```

## Installation

Clone the repository and install dependencies:

```bash
git clone <repo-url> theseus
cd theseus

# Install frontend/workspace dependencies
pnpm install

# Download Go module dependencies
cd apps/backend && go mod download && cd ../..
cd packages/go-lib && go mod download && cd ../..
```

## Running the Application

For day-to-day development, run the app directly (no Docker) to get hot reload and fast iteration. Use the Docker flow below to verify production builds or deploy.

### Both frontend and backend (recommended)

```bash
make dev
```

- Frontend (Vite dev server): http://localhost:5173
- Backend API: http://localhost:8080

### Individually

```bash
make frontend   # SolidJS dev server only
make backend    # Go API server only (port :8080)
```

## Available Commands

| Command | Description |
|---------|-------------|
| `make dev` | Run frontend and backend concurrently |
| `make frontend` | Run the Vite dev server only |
| `make backend` | Run the Go API only |
| `make build-frontend` | Type-check and build the frontend for production (`apps/frontend/dist`) |
| `make build-backend` | Compile the backend binary (`apps/backend/theseus-api`) |
| `make format` | Format TypeScript (pnpm) and Go (`go fmt`) code |
| `make test-frontend` | Run TypeScript tests |
| `make test-backend` | Run Go tests |
| `make clean` | Remove all build artifacts |
| `make clean-frontend` | Remove frontend build artifacts only |
| `make clean-backend` | Remove backend binary only |
| `make docker-build` | Build both Docker images |
| `make docker-build-backend` | Build the backend Docker image only |
| `make docker-build-frontend` | Build the frontend Docker image only |
| `make docker-run-backend` | Run the backend container (`:8080`) |
| `make docker-run-frontend` | Run the frontend container (`:8081`) |

## Production Build

```bash
# Build both
make build-frontend
make build-backend

# Run the compiled API binary
./apps/backend/theseus-api

# Preview the built frontend locally
cd apps/frontend && pnpm preview
```

## Docker

Dockerfiles live in [infra/docker](infra/docker). Use this flow to verify production artifacts locally or to deploy — not for active development, since containers have no hot reload and every code change requires a rebuild.

The [Makefile](Makefile) wraps the common commands:

```bash
make docker-build          # build both images
make docker-run-backend    # backend at http://localhost:8080
make docker-run-frontend   # frontend at http://localhost:8081
```

The run targets assume the images already exist — run `make docker-build` first (and re-run it after any code change).

Or run docker directly. Build the backend image from the repository root (required, since `go.work` spans multiple modules):

```bash
docker build -f infra/docker/backend.Dockerfile -t theseus-backend .
```

Build the frontend image using `apps/frontend` as the build context:

```bash
docker build -f infra/docker/frontend.Dockerfile -t theseus-frontend apps/frontend
```

Run the backend container:

```bash
docker run --rm -p 8080:8080 theseus-backend
```

Run the frontend container:

```bash
docker run --rm -p 8081:80 theseus-frontend
```

Then open:

- Frontend: http://localhost:8081
- Backend: http://localhost:8080

If the frontend needs to call the backend in production, configure the API base URL or route `/api` through nginx to the backend container.

## How It Works

1. **Prompt** — A writing prompt (word, object, idea, ...) is presented to the user.
2. **Write** — The user writes a short story based on the prompt; an AI generates its own story from the same prompt.
3. **Matchup** — The two stories are paired into an anonymized `Matchup`.
4. **Vote** — Other users read both stories and `Vote` for the one they prefer.
5. **Score** — The author sees the percentage of voters who preferred their story over the AI's, plus additional metrics.

Shared domain types (`Story`, `Matchup`, `Vote`) are defined in [packages/types/src/index.ts](packages/types/src/index.ts) and mirrored by the Go domain packages under [apps/backend/internal](apps/backend/internal).

## Development Notes

- The repo uses **Go workspaces** (`go.work`) — run Go commands from within each module directory.
- The repo uses **pnpm workspaces** — target a package with `pnpm --filter <name>`, e.g. `pnpm --filter frontend dev`.
- Shared TypeScript types can be consumed by the frontend via the `@theseus/types` workspace package.
- Run `make format` before committing to keep Go and TypeScript code consistently formatted.

## Troubleshooting

- **`pnpm: command not found`** — Run `corepack enable` or `npm install -g pnpm`.
- **Wrong pnpm version** — The root `package.json` enforces pnpm `^11.18.0` and will auto-download it (`onFail: "download"`).
- **Go version errors** — Ensure `go version` reports 1.26 or newer.
- **Port already in use** — The backend binds to `:8080` and Vite to `:5173`; stop conflicting processes or change the port in [apps/backend/cmd/api/main.go](apps/backend/cmd/api/main.go) / [apps/frontend/vite.config.ts](apps/frontend/vite.config.ts).

## License

ISC
