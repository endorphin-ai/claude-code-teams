# /create-el-capitan

Create the el-capitan orchestration layer for a squad — generates the `/el-capitan` orchestrator command, workflow YAML, and `/invoke-el-capitan` delegation endpoint.

## Context

$ARGUMENTS

## Instructions

You are the Agent Squad Architect running in El-Capitan Creation mode. Your job is to generate the orchestration layer for a squad.

### Parse Arguments

Expected format: `/create-el-capitan {squad-name}`

- **squad-name**: kebab-case name identifying the squad domain (e.g., `flutter-app`, `api-backend`, `data-pipeline`)

If the squad name is missing, ask interactively.

### Process

#### 1. Discover Squad Agents

Scan `.claude/agents/` for agents related to the squad domain:

```
Glob: .claude/agents/*.md
```

Filter for agents whose name, description, or capabilities match the `{squad-name}` domain. Exclude Architect infrastructure (`AGENT_TEMPLATE.md`).

If no matching agents are found, inform the user and suggest they build the squad first with `/architect build {squad-name}`.

#### 2. Analyze Agent Pipeline

For each discovered agent, identify:
- **Inputs**: What does it consume?
- **Outputs**: What does it produce?
- **Dependencies**: Which agents must run before it?
- **Parallel opportunities**: Which agents can run concurrently?

Map the natural flow: which agent's output feeds into which agent's input.

#### 3. Design Orchestration Flow

Based on the analysis, design:
- **Phase order**: Sequential phases with named stages
- **Parallel groups**: Agents within a phase that can run simultaneously
- **Validation gates**: Pass/fail criteria between phases
- **Context handoff**: Typed fields passed between phases
- **Error handling**: Retry strategy per phase

Present the proposed flow to the user for approval before generating files.

#### 4. Generate `/el-capitan` Orchestrator Command

Create `.claude/commands/el-capitan.md` using the El-Capitan Orchestrator Template from `.claude/AI-Agent-Squad-Architect.md` Section 5.

The command must include:
- Instructions to read the workflow YAML and execute the pipeline
- For each phase: invoke the Task tool with `subagent_type` set to the phase's agent name from the YAML
- Context handoff rules — pass only what each phase needs
- Validation gates checked after each phase
- Error handling (retry 2x then escalate to user)
- Critical rules: NEVER read worker agent .md files, NEVER do workers' jobs

#### 5. Generate Workflow YAML

Create `.claude/workflows/{squad-name}.yaml` with the declarative pipeline definition:

```yaml
workflow_definition:
  name: {squad-name}
  description: "{what this workflow accomplishes}"
  version: "1.0"

  phases:
    - name: {phase-name}
      agent: {agent-name}
      input: [{field-names}]
      output: [{field-names}]
      validation: "{success criteria}"
      depends_on: []

    - name: {phase-name}
      agent: {agent-name}
      input: [{field-names}]
      output: [{field-names}]
      validation: "{success criteria}"
      depends_on: [{previous-phase}]

  error_handling:
    retry_count: 2
    on_failure: "escalate_to_user"

  context_schema:
    user_request: "string"
    decisions: "list[string]"
    # phase-specific fields added here
```

Ensure the `.claude/workflows/` directory exists before writing.

#### 6. Generate Agent-Internal Command

Generate `.claude/commands/invoke-el-capitan.md` — This is what WORKER AGENTS reference in their final Task Tracking step to signal completion. Users never call this directly.

```markdown
# /invoke-el-capitan

Agent-internal: delegate results back to the el-capitan orchestrator. This command is referenced by worker agents in their final Task Tracking step. Users should use `/el-capitan` instead.

## Context

$ARGUMENTS

## Instructions

This command is invoked by worker agents at the end of their execution to signal completion and hand off results to el-capitan. The worker reports:
- What was accomplished
- Outputs produced (with file paths/data)
- Any issues encountered
- Recommendations for the next phase
```

If this command already exists, skip it.

#### 7. Report

Output a summary of what was created:

```
## El-Capitan Created: {squad-name}

### Files Generated
1. `.claude/commands/el-capitan.md` — Orchestrator command (reads YAML, dispatches workers)
2. `.claude/workflows/{squad-name}.yaml` — Workflow pipeline definition
3. `.claude/commands/invoke-el-capitan.md` — Agent-internal delegation endpoint

### Pipeline Overview
User invokes: /el-capitan {request}
         |  (reads .claude/workflows/*.yaml)
         |
         +-- Phase 0: pm-{squad} -> PRD
         |         | [gate: PRD has features + criteria]
         +-- Phase 1: {agent} -> {output}
         |         | [validation gate]
         +-- Phase 2: {agent} -> {output}
         |         | [validation gate]
         +-- Phase 3: {agent} -> {final output}
         |
         v
    Final Report to User

### Next Steps
- Run `/el-capitan --dry-run {your request}` to preview the workflow
- Run `/el-capitan {your request}` to execute
```

### Quality Checklist

Before finalizing, verify:

- [ ] `/el-capitan` command has orchestration instructions (not routing logic)
- [ ] `/el-capitan` command NEVER reads worker agent .md files
- [ ] All squad workers are referenced in the workflow YAML pipeline
- [ ] Every phase has a validation gate
- [ ] Context handoff schemas have typed fields (not "pass everything")
- [ ] Workflow YAML phases match the designed pipeline
- [ ] `/invoke-el-capitan` command exists for worker delegation
- [ ] Error handling specifies retry + escalation behavior

### Edge Cases

- If no agents exist for the squad: inform user, suggest `/architect build {squad-name}` first
- If only 1 agent exists: create a minimal el-capitan that just dispatches and validates
- If agents have incompatible output/input formats: note the mismatch and add an adaptation step in the pipeline
- If a workflow YAML already exists for this squad: ask user whether to overwrite or merge
