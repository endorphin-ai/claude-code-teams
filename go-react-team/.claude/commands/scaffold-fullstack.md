# /scaffold-fullstack

Initialize a new fullstack Go + React project with standard directory structure, configs, and Docker Compose.

## Context

$ARGUMENTS

## Instructions

### Purpose

One-time project scaffolding — creates the foundation directory structure, configuration files, and Docker setup for a fullstack Go backend + React frontend application. This is NOT a pipeline phase — run it once before using `/el-capitan`.

### Parse Arguments

Extract from `$ARGUMENTS`:
- `--name` or `-n`: Project name (used for go module, package.json name). Default: current directory name
- `--go-module`: Go module path (e.g., `github.com/user/project`). Default: `github.com/user/{project-name}`
- `--db`: Database type. Default: `postgres`
- `--port-api`: Backend port. Default: `8080`
- `--port-ui`: Frontend dev port. Default: `5173`

### Project Structure to Create

```
{project-root}/
├── backend/
│   ├── cmd/
│   │   └── server/
│   │       └── main.go              # Entry point with graceful shutdown
│   ├── internal/
│   │   ├── config/
│   │   │   └── config.go            # Environment-based configuration
│   │   ├── handler/                  # HTTP handlers (empty, agents fill these)
│   │   ├── service/                  # Business logic (empty)
│   │   ├── repository/              # Database queries (empty)
│   │   ├── model/                    # Data models (empty)
│   │   ├── middleware/
│   │   │   └── middleware.go         # CORS, logging, recovery, auth middleware
│   │   └── router/
│   │       └── router.go            # Chi router setup
│   ├── migrations/                   # SQL migration files (empty)
│   ├── go.mod                        # Go module file
│   ├── go.sum                        # Go sum file (empty)
│   ├── Dockerfile                    # Multi-stage Docker build
│   └── .env.example                  # Environment variable template
├── frontend/
│   ├── src/
│   │   ├── api/
│   │   │   └── client.ts            # API client base configuration
│   │   ├── components/              # Shared UI components (empty)
│   │   ├── pages/                   # Page components (empty)
│   │   ├── hooks/                   # Custom hooks (empty)
│   │   ├── types/
│   │   │   └── index.ts             # Shared TypeScript types (empty)
│   │   ├── utils/                   # Utility functions (empty)
│   │   ├── context/                 # React context providers (empty)
│   │   ├── routes/
│   │   │   └── index.tsx            # React Router configuration
│   │   ├── styles/
│   │   │   └── index.css            # Tailwind CSS imports
│   │   ├── test/
│   │   │   ├── setup.ts             # Test setup with MSW
│   │   │   └── handlers.ts          # MSW API mock handlers (empty)
│   │   ├── App.tsx                   # Root App component
│   │   └── main.tsx                  # Vite entry point
│   ├── public/                       # Static assets
│   ├── index.html                    # HTML template
│   ├── vite.config.ts                # Vite configuration with proxy
│   ├── tsconfig.json                 # TypeScript configuration (strict)
│   ├── tailwind.config.js            # Tailwind CSS configuration
│   ├── postcss.config.js             # PostCSS configuration
│   ├── package.json                  # Dependencies
│   ├── Dockerfile                    # Multi-stage Docker build for React
│   └── .env.example                  # Environment variable template
├── docker-compose.yml                # Docker Compose with Go, React, PostgreSQL
├── .gitignore                        # Comprehensive gitignore
├── Makefile                          # Common commands (dev, build, test, migrate)
└── README.md                         # Project overview with setup instructions
```

### Process

1. Verify we're in the project root directory
2. Create the directory structure
3. Create all config and boilerplate files with sensible defaults
4. Initialize Go module: `go mod init {go-module}`
5. Initialize frontend: create package.json with dependencies (do NOT run npm install — user may want to review)
6. Create Docker Compose with services: api (Go), web (React), db (PostgreSQL), with health checks
7. Create Makefile with targets: `dev`, `build`, `test`, `lint`, `migrate-up`, `migrate-down`, `docker-up`, `docker-down`
8. Report what was created

### Output

```
## Scaffold Complete

### Files Created
| Directory | Files | Purpose |
|-----------|-------|---------|
| backend/ | main.go, config.go, router.go, middleware.go, Dockerfile | Go API foundation |
| frontend/ | App.tsx, main.tsx, vite.config.ts, tsconfig.json, package.json | React UI foundation |
| root | docker-compose.yml, Makefile, .gitignore, README.md | Project infrastructure |

### Next Steps
1. `cd frontend && npm install` — Install frontend dependencies
2. `cd backend && go mod tidy` — Download Go dependencies
3. `/el-capitan {your feature request}` — Start building features
```

### Edge Cases

- If files already exist: WARN and skip (never overwrite existing files)
- If go is not installed: warn but continue creating files
- If node is not installed: warn but continue creating files
