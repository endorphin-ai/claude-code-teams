# 🍕 One Pizza Team

**One Pizza Team** is a set of AI agents capable of working together — from PRD to PR — as a fully autonomous development squad.

## Available Teams

| Team | Description |
|------|-------------|
| [Go + React Team](./go-react-team) | Fullstack squad with Go backend and React frontend |

## How It Works

Every team is orchestrated by **El Capitan** — the main orchestrator that manages the entire squad through a standard pipeline:

```
PRD → Architecture → Backend → Frontend → Code Review → Tests → Acceptance
```

Each team can start working immediately. You can also run a **dry-run simulation** — agents won't write any code, they'll just plan and simulate the work:

```bash
/el-capitan --dry-run "Build an expense tracker"
```

Or run for real:

```bash
/el-capitan "Build an expense tracker"
```

## Getting Started

Just copy the `.claude` folder into your project and start working:

```bash
cp -r go-react-team/.claude your-project/
cd your-project
claude code
```

Every team comes with agents, skills, and commands that you can adjust for your specific needs.

---

Happy vibecoding! 🚀
