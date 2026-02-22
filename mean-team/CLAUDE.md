# MEAN Stack App Builder

AI-powered development squad for building MEAN stack (MongoDB + Express + React + Node.js) web applications from scratch. Describe what you want to build and the squad handles everything — from PRD to tested, reviewed code.

## AI Agent Squad

### Quick Start

```
# One-time project setup (creates folders, installs dependencies, configs)
/scaffold-mean my-app-name

# Run the full squad pipeline
/el-capitan Build a blog platform with user auth, posts, and comments

# Preview what the squad will do (no file changes)
/el-capitan --dry-run Build a blog platform with user auth, posts, and comments
```

### Available Agents

| Agent | Role | Model | Skill |
|-------|------|-------|-------|
| `pm-mean` | Product Manager — writes PRDs, performs acceptance review | sonnet | pm-mean |
| `db-architect-mean` | MongoDB Expert — designs collections, schemas, indexes | sonnet | mongodb-mean |
| `api-architect-mean` | API Architect — designs REST endpoints, auth flows, contracts | sonnet | express-api-mean |
| `react-architect-mean` | React Architect — designs component trees, routing, state | sonnet | react-design-mean |
| `backend-mean` | Backend Dev — implements Express + MongoDB server | sonnet | backend-mean |
| `frontend-mean` | Frontend Dev — implements React app | sonnet | frontend-mean |
| `reviewer-mean` | Code Reviewer — reviews code, can loop back to devs | sonnet | code-review-mean |
| `qa-backend-mean` | Backend QA — writes Jest + Supertest tests | sonnet | qa-backend-mean |
| `qa-frontend-mean` | Frontend QA — writes React Testing Library + MSW tests | sonnet | qa-frontend-mean |

### Squad Pipeline

```
/el-capitan {request}
       │  (reads .claude/workflows/mean-app.yaml)
       │
       ├─► Phase 0: pm-mean → PRD (features, acceptance criteria)
       │         │ [gate: PRD has features + criteria]
       │
       ├─► Phase 1: db-architect-mean → DB Design (collections, schemas, indexes)
       │         │ [gate: collections with schemas defined]
       │
       ├─► Phase 2: api-architect-mean → API Design (endpoints, contracts, auth)
       │         │ [gate: endpoints with request/response schemas]
       │
       ├─► Phase 3: react-architect-mean → React Design (components, routing, state)
       │         │ [gate: component tree + routing plan]
       │
       ├─► Phase 4: backend-mean → Express + MongoDB Code
       │         │ [gate: server.js + models + routes]
       │
       ├─► Phase 5: frontend-mean → React App Code
       │         │ [gate: App.jsx + pages + API client]
       │
       │   ┌─── REVIEW LOOP (max 2 iterations) ───┐
       ├─► │ Phase 6: reviewer-mean → Code Review   │
       │   │   PASS → continue | FAIL → back to devs│
       │   └────────────────────────────────────────┘
       │
       ├─► Phase 7: qa-backend-mean → Backend Tests (parallel)
       │   Phase 8: qa-frontend-mean → Frontend Tests (parallel)
       │         │ [gate: tests pass]
       │
       ├─► Phase 9: pm-mean → Acceptance Review (validates against PRD)
       │         │ [gate: all features verified]
       │
       ▼
  Final Report
```

### Available Commands

| Command | Purpose |
|---------|---------|
| `/el-capitan` | Run the full squad pipeline — dispatches all agents in order |
| `/scaffold-mean` | One-time project setup (folders, dependencies, configs) |

### Invoking Individual Agents

Each agent can be invoked directly via the Task tool:

```
Task(subagent_type="pm-mean", prompt="Write a PRD for a todo app with user auth")
Task(subagent_type="db-architect-mean", prompt="Design the MongoDB schema for: {PRD}")
Task(subagent_type="api-architect-mean", prompt="Design the REST API for: {PRD + DB design}")
Task(subagent_type="react-architect-mean", prompt="Design the React frontend for: {PRD + API design}")
Task(subagent_type="backend-mean", prompt="Implement the backend: {DB design + API contracts}")
Task(subagent_type="frontend-mean", prompt="Implement the frontend: {React design + API contracts}")
Task(subagent_type="reviewer-mean", prompt="Review the code: {backend + frontend summaries}")
Task(subagent_type="qa-backend-mean", prompt="Write backend tests: {API contracts + backend summary}")
Task(subagent_type="qa-frontend-mean", prompt="Write frontend tests: {React design + frontend summary}")
```

### Skills

| Skill | Used By | Purpose |
|-------|---------|---------|
| pm-mean | pm-mean | PRD writing, user stories, acceptance criteria, MoSCoW prioritization |
| mongodb-mean | db-architect-mean | Mongoose schema design, indexes, embed vs reference patterns |
| express-api-mean | api-architect-mean | REST conventions, Express middleware, JWT auth, error contracts |
| react-design-mean | react-architect-mean | Component architecture, React Router, state management |
| backend-mean | backend-mean | Express implementation, Mongoose CRUD, middleware, validation |
| frontend-mean | frontend-mean | React 18+, Vite, hooks, Axios, responsive UI patterns |
| code-review-mean | reviewer-mean | MEAN best practices, security audit, architecture compliance |
| qa-backend-mean | qa-backend-mean | Jest, Supertest, MongoDB Memory Server, API testing |
| qa-frontend-mean | qa-frontend-mean | React Testing Library, MSW, component/page/hook testing |

### Project Structure

```
.claude/
├── agents/              # 9 subagent definitions
│   ├── pm-mean.md
│   ├── db-architect-mean.md
│   ├── api-architect-mean.md
│   ├── react-architect-mean.md
│   ├── backend-mean.md
│   ├── frontend-mean.md
│   ├── reviewer-mean.md
│   ├── qa-backend-mean.md
│   └── qa-frontend-mean.md
├── skills/              # 9 skill playbooks
│   ├── pm-mean/         (SKILL.md, FORMAT.md, VOICE.md, DRY_RUN.md, workflows/)
│   ├── mongodb-mean/
│   ├── express-api-mean/
│   ├── react-design-mean/
│   ├── backend-mean/
│   ├── frontend-mean/
│   ├── code-review-mean/
│   ├── qa-backend-mean/
│   └── qa-frontend-mean/
├── commands/            # User-facing commands
│   ├── el-capitan.md    # Pipeline orchestrator
│   └── scaffold-mean.md # One-time project setup
├── workflows/
│   └── mean-app.yaml    # Pipeline definition (phases, gates, context schema)
├── agent-memory/        # Per-agent persistent memory
└── scripts/             # Scaffold scripts (init-skill.sh, init-agent.sh)
```
