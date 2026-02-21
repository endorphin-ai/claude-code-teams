# /create-agent

Interactively create a new component: agent (subagent), command, skill, orchestrator, or MCP server.

## Context

$ARGUMENTS

## Instructions

You are the Agent Squad Architect running in Create mode. Read `.claude/AI-Agent-Squad-Architect.md` for full procedures and templates.

### Parse Arguments

Expected format: `/create-agent [type] [name] [description]`

- **type**: `agent` | `command` | `skill` | `orchestrator` | `mcp`
- **name**: kebab-case name
- **description**: (optional) one-line purpose

If arguments are missing, ask interactively.

### Process

1. **Understand Intent** — What problem does this component solve? What workflow phase does it serve?

2. **Check Squad Context** — Scan existing components to:
    - Avoid duplicating existing functionality
    - Identify components this new one should compose with
    - Find compatible input/output formats to adopt

3. **Design** — Produce a proposal including:
    - Purpose and trigger conditions
    - Inputs with formats
    - Outputs with formats
    - Integration points (what it feeds into, what feeds it)
    - Process steps

4. **Get Approval** — Present the proposal to the user. Iterate if needed.

5. **Implement** — Use the correct scaffold for each type:

    **For `agent` (subagent):**
    - First ensure the skill exists. If not, run `/create-skill {skill-name}` first.
    - Run `bash .claude/scripts/init-agent.sh {agent-name} {skill-name} {model} {color}` — this reads `.claude/agents/AGENT_TEMPLATE.md` at runtime and produces the correct agent structure with all required sections.
    - Customize the generated agent file with domain-specific Identity, Instructions, and Quality Standards.

    **For `skill`:**
    - Run `/create-skill {name}` — this scaffolds via `init-skill.sh` and fills via `skill-creator/SKILL.md` guidance.

    **For `command`:**
    - Create `.claude/commands/{name}.md` with: H1 title, `$ARGUMENTS` context, Instructions section.

    **For `orchestrator`:**
    - Run `/create-el-capitan {squad-name}` — generates the `/el-capitan` orchestrator command, workflow YAML, and `/invoke-el-capitan` endpoint.

    **For `mcp`:**
    - Create MCP server scaffold with tool definitions in `.claude/mcp.json`.

6. **Create Eval Plan** — Write 2-3 test prompts with expected outcomes.

7. **Update Squad Documentation** — Note the new component's role in the ecosystem.

### Quality Checklist

Before finalizing, verify the new component has:

- [ ] Clear one-line purpose
- [ ] Specific trigger conditions (when to use / when NOT to use)
- [ ] Defined inputs with format specs
- [ ] Defined outputs with format specs
- [ ] At least 2 concrete examples
- [ ] Edge case handling
- [ ] Integration points documented
- [ ] For agents: `skills:` field populated, Task Tracking with TaskCreate JSON syntax
- [ ] For skills: SKILL.md, FORMAT.md, VOICE.md, DRY_RUN.md, and workflows/ all exist
