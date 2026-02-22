![go-react-team](go-react-team.png)

The Full Toolkit in Claude Code

Slash Commands (.claude/commands/\*.md)
These are just user-triggered prompts. You type /something, it injects a prompt template. Simple, static, no intelligence of their own. They're entry points, not agents.

Skills (SKILL.md)
Detailed instruction sets — like a playbook. They tell Claude how to do something complex. Still passive though — they're reference docs that get loaded into context.

Agents (subagents via the Task tool)
This is where the real power is. Claude Code can spawn independent sub-agents — separate Claude instances that run in parallel, each with their own context and instructions. An agent file (like agents/executor.md) defines a role, and the coordinator spawns it with Task(). These agents can work simultaneously on different parts of a problem.

MCP Servers
External tool integrations — give Claude access to APIs, databases, services. They extend what agents can do.

CLAUDE.md
The project-level system prompt. Sets the personality and default behavior for everything.

Run

```
claude code
```

Run for agent simulation

```
/el-capitan --dry-run "Build Expence tracker"
```

One-time setup: 
```
/scaffold-mean my-app-name — creates project structure, installs deps
```

Full pipeline:

```
/el-capitan  "Build X"
```

```

  /el-capitan {request}
       │
       ├─► Phase 0: pm-mean → PRD
       ├─► Phase 1: db-architect-mean → MongoDB schema
       ├─► Phase 2: api-architect-mean → API design
       ├─► Phase 3: react-architect-mean → React architecture
       ├─► Phase 4: backend-mean → Express + MongoDB code
       ├─► Phase 5: frontend-mean → React app code
       ├─► Phase 6: reviewer-mean → PASS/FAIL (loops to 4+5 if FAIL, max 2x)
       ├─► Phase 7: qa-backend-mean → Backend tests  ┐
       ├─► Phase 8: qa-frontend-mean → Frontend tests ┘ (parallel)
       └─► Phase 9: pm-mean --review → Acceptance verdict

```



