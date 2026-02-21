# /el-capitan

Orchestrate the full fullstack development pipeline. Read the workflow YAML, dispatch workers via Task tool, validate gates, report results.

## Context

$ARGUMENTS

## Instructions

### Parse Input

Extract the user request from `$ARGUMENTS`. Detect flags:
- `--dry-run` — dispatch real workers but append `--dry-run` to each prompt so workers plan instead of write
- `--interactive` — pause after each phase for user review

### Load Workflow

Read `.claude/workflows/fullstack.yaml`. This YAML defines: phases (name, agent, input, output, validation, depends_on), error handling, and context schema.

### Execute Pipeline

For each phase defined in the workflow YAML, in dependency order:

1. Use TaskCreate to create a task for this phase (subject = phase name, activeForm = "Running {phase name}")
2. Mark the task as in_progress
3. Invoke the Task tool:
   - Set `subagent_type` to the phase's `agent` field from the YAML
   - Set `prompt` to include: the original user_request, outputs collected from previous phases that this phase's `input` field lists, and the phase's `mode` field if present
   - If `--dry-run` is active, append the string `--dry-run` to the end of the prompt
4. Collect the return value from the Task tool — this is the worker's output
5. Validate the phase's gate: check the `validation` field from the YAML against the worker's output
6. If gate passes: mark task completed, store the output keyed by the phase's `output` field names
7. If gate fails: retry up to 2 times with the same prompt. If still failing, stop and ask the user whether to retry, skip, or abort.

### Parallel Phase Handling

When multiple phases share the same `depends_on` prerequisites and those prerequisites are complete, dispatch those phases **concurrently** using multiple Task tool calls in the same message. In this workflow:
- `testing-go` and `testing-react` both depend only on `review` — dispatch them in parallel.

### Context Handoff

Each phase's prompt must include:
- The original `user_request` (always)
- Outputs from previous phases that this phase's `input` field lists in the YAML
- If `--dry-run`, the `--dry-run` flag
- If the phase has a `mode` field, include that flag in the prompt

Pass only what the YAML says the next phase needs. Do not pass "everything."

### Final Report

After all phases complete (or if the pipeline stops early), present:

```
## Pipeline Report: fullstack

### Phase Results
| Phase | Agent | Status | Key Output |
|-------|-------|--------|------------|
| requirements | pm-fullstack | ✅/❌ | ... |
| design | architect-fullstack | ✅/❌ | ... |
| backend | go-dev | ✅/❌ | ... |
| frontend | react-dev | ✅/❌ | ... |
| review | architect-fullstack | ✅/❌ | ... |
| testing-go | tester-go | ✅/❌ | ... |
| testing-react | tester-react | ✅/❌ | ... |
| acceptance | pm-fullstack | ✅/❌ | ... |

### Overall Status: [COMPLETE / PARTIAL / FAILED]

### Deliverables
- Backend: [list of Go files created]
- Frontend: [list of React files created]
- Tests: [Go test files + React test files]

### Acceptance Verdict: [PASS / CONDITIONAL PASS / FAIL]
```

### Critical Rules

NEVER read worker agent .md files (`.claude/agents/*.md`). You do not need to understand what workers do. You only need to invoke them via Task tool using the agent name from the workflow YAML and collect their output.

NEVER describe, plan, or execute what a worker would do. You are the dispatcher. Workers are autonomous — they have their own skills and instructions. Your job is: invoke, collect, validate, pass forward.

NEVER skip validation gates between phases.

ALWAYS use TaskCreate to track each phase as a task.

ALWAYS dispatch workers using the Task tool — this spawns a real subagent with its own context window.

ALWAYS pass the `mode` field (e.g., `--review`) when a phase specifies one — this tells the worker which operating mode to use.
