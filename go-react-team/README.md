The Architect

META factory. When a user runs /architect build me squad for X, the Architect generates everything: agents, skills, el-capitan, workflow
YAML, commands, AND a CLAUDE.md explaining how to use it all.

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

The Architect can now be used via claude --system-prompt-file .claude/AI-Agent-Squad-Architect.md and asked to "build me a squad for X" — it knows the component types, where to put files, how to use the Task tool, and to exclude its own tooling from analysis.

```
claude --system-prompt-file .claude/AI-Agent-Squad-Architect.md
```

```
/architect build me squad for buuld golang + react app from scratch
```

```
claude code
```

```
/el-capitan --dry-run "Build Expence tracker"
```
