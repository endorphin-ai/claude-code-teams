El-Capitan Orchestration System — Project Brief

What It Is

A command-driven orchestration system where /el-capitan runs in the main thread and dispatches autonomous worker agents via Task tool. The main thread is the
conductor — it reads a declarative workflow YAML, invokes workers in sequence, validates outputs at each gate, and delivers a final report.

Architecture

User: /el-capitan build a todo app
│
/el-capitan (COMMAND — main thread)
Reads .claude/workflows/\*.yaml
│
├── Task(pm-fullstack) → PRD
│ [gate: features + acceptance criteria]
├── Task(go-dev) → Go backend
│ [gate: go.mod + handlers + main.go]
├── Task(react-dev) → React frontend
│ [gate: package.json + App.tsx + API client]
├── Task(qa-fullstack) → Tests
│ [gate: test files + 80% criteria coverage]
│
▼
Final Report to User

Two layers only: Command (dispatcher) → Workers (subagents). No intermediate orchestrator agent.

How It Works

1. /el-capitan is a command (.claude/commands/el-capitan.md) — runs in the main thread, not a subagent
2. It reads the workflow YAML (.claude/workflows/{name}.yaml) — declarative pipeline definition with phases, agents, inputs, outputs, validation gates
3. For each phase, it invokes the Task tool with subagent_type set to the agent name from the YAML — workers are autonomous, they have their own skills and
   instructions
4. It validates gates between phases — if a gate fails, retry 2x then escalate to user
5. It passes context forward — each phase gets user_request + outputs from previous phases, typed per the YAML schema

Design Principles

- Command, not agent — the orchestrator is a command running in the main thread. No subagent context window that could drift or go rogue.
- Dispatcher, not doer — /el-capitan never reads worker .md files, never understands what workers do, never does their work. It invokes, collects, validates,
  passes forward.
- YAML-driven — the pipeline is declared in a YAML file. The command reads it at runtime. Change the YAML, change the pipeline.
- Star topology — main thread dispatches all workers. Workers report back via Task tool return value. No worker-to-worker communication.

The Factory

We build the factory, not the products. Two factory files generate the entire orchestration layer:
┌──────────────────────────────────────────────────────────────┬──────────────────────────────────────────────────────────────────────────────┐
│ Factory File │ What It Generates │
├──────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────┤
│ AI-Agent-Squad-Architect.md (El-Capitan Template, Section 5) │ Template for the /el-capitan command │
├──────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────┤
│ commands/create-el-capitan.md │ Generates: /el-capitan command + workflow YAML + /invoke-el-capitan endpoint │
└──────────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────────────────────┘
When you run /architect build {domain} or /create-el-capitan {name}, the factory produces the orchestration layer. Workers and skills are generated separately
by their own factory components (AGENT_TEMPLATE.md, init-agent.sh, init-skill.sh).

Components
┌───────────────────────────────┬─────────┬────────────────────────────────────────────────────────────────────────┐
│ Component │ Type │ Role │
├───────────────────────────────┼─────────┼────────────────────────────────────────────────────────────────────────┤
│ /el-capitan │ Command │ Orchestrator — reads YAML, dispatches workers, validates gates │
├───────────────────────────────┼─────────┼────────────────────────────────────────────────────────────────────────┤
│ workflows/{name}.yaml │ Data │ Pipeline declaration — phases, agents, gates, context schema │
├───────────────────────────────┼─────────┼────────────────────────────────────────────────────────────────────────┤
│ /invoke-el-capitan │ Command │ Worker signaling endpoint — workers reference this in their final task │
├───────────────────────────────┼─────────┼────────────────────────────────────────────────────────────────────────┤
│ pm-_, go-dev, react-dev, qa-_ │ Agents │ Autonomous workers — each has its own skill as playbook │
└───────────────────────────────┴─────────┴────────────────────────────────────────────────────────────────────────┘

AI-Agent-Squad-Architect.md — Interaction Model

Entry Point

AI-Agent-Squad-Architect.md is NOT called directly. It's a system prompt — a brain that gets loaded by commands. The user never touches it. Commands are the  
 entry points.

How It Works

User types a command  
 │
Command .md file (entry point)
Loads AI-Agent-Squad-Architect.md as system prompt
Claude becomes the Architect
│
Architect executes the requested mode

Command Map

/architect — The main hub. Takes a mode argument, loads the full Architect brain.

/architect audit → Mode 1: Scan & analyze the squad
/architect optimize → Mode 2: Audit + fix inefficiencies
/architect create → Mode 3: Build a new component interactively
/architect compose → Mode 4: Chain agents into a pipeline
/architect insight → Mode 5: Generate intelligence reports
/architect evolve → Mode 6: Full lifecycle review
/architect build → Mode 7: Design & create a complete squad from scratch

Specialized shortcuts — Each wraps one Architect mode for quick access:
┌─────────────────────┬───────────────────────────────────────────────────────────┬──────────────────────────────────┐
│ Command │ What it does │ Loads Architect? │
├─────────────────────┼───────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ /create-agent │ Mode 3 shortcut — create agent/command/skill │ Yes │
├─────────────────────┼───────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ /create-el-capitan │ Generates orchestration layer (command + YAML + endpoint) │ Yes (Section 5) │
├─────────────────────┼───────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ /create-skill │ Creates skill via skill-creator workflow │ No — uses skill-creator/SKILL.md │
├─────────────────────┼───────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ /insight │ Mode 5 shortcut — health/gaps/performance reports │ Yes │
├─────────────────────┼───────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ /fleet-audit │ Quick audit — inventory + diagnostics │ Yes │
├─────────────────────┼───────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ /compose-agents │ Mode 4 shortcut — design pipelines │ Yes │
├─────────────────────┼───────────────────────────────────────────────────────────┼──────────────────────────────────┤
│ /generate-claude-md │ Generate CLAUDE.md documentation │ No — self-contained │
└─────────────────────┴───────────────────────────────────────────────────────────┴──────────────────────────────────┘
Two Independent Subsystems

AI-Agent-Squad-Architect.md skill-creator/SKILL.md
│ │
/architect /create-skill
/create-agent
/create-el-capitan
/insight
/fleet-audit
/compose-agents

5 commands load the Architect. 1 command loads skill-creator. 1 command is self-contained. They share the same project but are two separate brains.

The Flow for Building a Squad

1. User: /architect build fullstack
   → Loads Architect brain
   → Mode 7: designs squad, creates skills (via init-skill.sh),
   creates agents (via init-agent.sh), generates CLAUDE.md

2. User: /create-el-capitan fullstack
   → Loads Architect Section 5
   → Generates: /el-capitan command + workflow YAML + /invoke-el-capitan

3. User: /el-capitan build a todo app
   → Does NOT load Architect
   → Reads workflow YAML, dispatches workers via Task tool

Step 1-2 = factory runs (build the machine). Step 3 = machine runs (produce the product).

> I'm your Agent Squad Architect. I can analyze your existing agents, optimize
> them, create new ones, build orchestrators, and generate insight reports.
>
> What would you like to do?
>
> 1. **Audit** — Scan and analyze your current Agent Squad
> 2. **Optimize** — Find and fix inefficiencies
> 3. **Create** — Build a new command, skill, subagent, or orchestrator
> 4. **Compose** — Chain agents into an orchestrated workflow
> 5. **Insight** — Generate a specific report (health, gaps, performance)
> 6. **Evolve** — Full lifecycle review and improvement
> 7. **Build** — Design and create a complete squad from scratch for a domain
>    nt calls it as part of a larger workflow. That's what makes a real squad — not a collection of isolated scripts, but an interconnected system where commands are shared vocabulary, skills are shared knowledge, agents are shared workers, and MCP is shared capabilities.
