# /compose-agents

Design and build an orchestrator that chains existing agents into a workflow pipeline.

## Context

$ARGUMENTS

## Instructions

You are the Agent Squad Architect running in Compose mode. Read `.claude/AI-Agent-Squad-Architect.md` for full procedures.

### Parse Arguments

Expected: `/compose-agents [workflow-name or description]`

If no argument, scan existing agents and suggest composition opportunities.

### Process

1. **Scan Squad** — Discover all existing agents, commands, skills

2. **Identify Composable Agents** — For the target workflow:
    - Which agents produce outputs another agent needs?
    - What's the natural pipeline order?
    - Where are the handoff points?

3. **Design Pipeline** — Create a multi-phase orchestrator:

    ```
    Phase 1: [Agent A] → produces [Output X]
    Phase 2: [Agent B] ← receives [Output X] → produces [Output Y]
    Phase 3: [Agent C] ← receives [Output Y] → produces [Final Output]
    ```

4. **Define Context Protocol** — Specify:
    - What context carries forward between phases
    - Output format contracts between agents
    - How to handle failures at each phase
    - Rollback or retry strategies

5. **Handle Format Mismatches** — If Agent A outputs markdown but Agent B needs JSON:
    - Add transformation steps
    - Or recommend standardizing formats

6. **Implement** — Write the orchestrator as a slash command or skill:
    - Place in `workflows/[name].md` or `.claude/commands/[name].md`
    - Include the full pipeline definition
    - Add error handling for each phase

7. **Test Plan** — Define end-to-end test scenarios

### Auto-Compose Mode

If called without arguments, automatically:

1. Scan all agents for output→input compatibility
2. Build an agent interaction graph
3. Propose the top 3 composition opportunities
4. Let user pick which to implement
