# Fullstack Go + React AI Agent Squad

This project uses an AI agent squad to build fullstack applications with a **Go backend** and **React frontend**. The squad automates the full development lifecycle from requirements to acceptance testing.

## Quick Start

```bash
# 1. Scaffold a new project (one-time)
/scaffold-fullstack --name my-app --go-module github.com/user/my-app

# 2. Build a feature (repeatable pipeline)
/el-capitan Build a user authentication system with login, registration, and password reset

# 3. Dry-run (plan without writing files)
/el-capitan --dry-run Add a product catalog with search and filtering
```

## Pipeline Architecture

```
/el-capitan {request}
     │
     ├─► Phase 0: pm-fullstack → PRD (requirements)
     ├─► Phase 1: architect-fullstack → Design doc (API, DB, components)
     ├─► Phase 2: go-dev → Go backend code
     ├─► Phase 3: react-dev → React frontend code
     ├─► Phase 4: architect-fullstack --review → Code review
     ├─► Phase 5a: tester-go ─────┐ → Go tests (parallel)
     ├─► Phase 5b: tester-react ──┘ → React tests (parallel)
     └─► Phase 6: pm-fullstack --review → Acceptance review
```

## Agents

| Agent | Role | Skill | Model |
|-------|------|-------|-------|
| `pm-fullstack` | Product Manager — writes PRDs, validates deliverables | `pm` | sonnet |
| `architect-fullstack` | System Architect — designs APIs/DB/components, reviews code | `system-design` | sonnet |
| `go-dev` | Go Backend Developer — implements REST APIs | `golang` | sonnet |
| `react-dev` | React Frontend Developer — implements UI | `react` | sonnet |
| `tester-go` | Go Test Engineer — writes/runs Go tests | `qa-go` | sonnet |
| `tester-react` | React Test Engineer — writes/runs React tests | `qa-react` | sonnet |

## Commands

### Development Pipeline
| Command | Purpose |
|---------|---------|
| `/el-capitan {request}` | Run the full development pipeline |
| `/scaffold-fullstack` | Initialize project structure (one-time) |

### Jira Integration (via Atlassian MCP)
| Command | Purpose |
|---------|---------|
| `/jira-create` | Create a Jira ticket |
| `/jira-update` | Update a Jira ticket |
| `/jira-comment` | Comment on a Jira ticket |
| `/jira-link` | Link two Jira tickets |

### Squad Management (Architect)
| Command | Purpose |
|---------|---------|
| `/architect audit` | Audit the squad |
| `/architect optimize` | Optimize the squad |
| `/squad-audit` | Quick squad health check |
| `/insight {type}` | Generate intelligence reports |

## Tech Stack

### Backend (Go)
- **Router:** Chi
- **Database:** PostgreSQL with pgx
- **Architecture:** Handler → Service → Repository (layered)
- **Config:** Environment variables
- **Logging:** slog (structured)

### Frontend (React)
- **Build:** Vite
- **Language:** TypeScript (strict)
- **State:** TanStack Query (server), Context (app)
- **Routing:** React Router v6
- **Forms:** React Hook Form + Zod
- **Styling:** Tailwind CSS
- **Testing:** Vitest + React Testing Library + MSW

## File Locations

```
.claude/
├── agents/                     # Agent definitions
│   ├── pm-fullstack.md         # Product Manager
│   ├── architect-fullstack.md  # System Architect
│   ├── go-dev.md               # Go Developer
│   ├── react-dev.md            # React Developer
│   ├── tester-go.md            # Go Tester
│   └── tester-react.md         # React Tester
├── skills/                     # Shared knowledge
│   ├── pm/                     # PM skill (PRD, acceptance)
│   ├── system-design/          # Architecture skill
│   ├── golang/                 # Go development skill
│   ├── react/                  # React development skill
│   ├── qa-go/                  # Go testing skill
│   ├── qa-react/               # React testing skill
│   └── jira/                   # Jira integration skill
├── commands/                   # Slash commands
│   ├── el-capitan.md           # Pipeline orchestrator
│   ├── scaffold-fullstack.md   # Project scaffolding
│   ├── jira-create.md          # Create Jira tickets
│   ├── jira-update.md          # Update Jira tickets
│   ├── jira-comment.md         # Comment on tickets
│   └── jira-link.md            # Link tickets
├── workflows/
│   └── fullstack.yaml          # Pipeline definition
├── agent-memory/               # Per-agent persistent memory
└── mcp.json                    # Atlassian MCP config
```

## MCP Setup (Jira)

To use Jira commands, set these environment variables:

```bash
export ATLASSIAN_SITE_URL="https://your-domain.atlassian.net"
export ATLASSIAN_USER_EMAIL="your-email@example.com"
export ATLASSIAN_API_TOKEN="your-api-token"
```

## Flags

| Flag | Effect |
|------|--------|
| `--dry-run` | Run full pipeline but produce plans instead of files |
| `--interactive` | Pause after each phase for review |
| `--review` | Trigger review mode (used by PM and Architect) |
| `--scaffold` | Create project skeleton only (go-dev, react-dev) |
| `--coverage` | Focus on test coverage gaps (tester agents) |
