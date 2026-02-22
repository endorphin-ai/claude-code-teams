# /el-capitan

Orchestrate the full MEAN stack development pipeline. Read the workflow YAML, dispatch workers via Task tool, validate gates, report results.

## Context

$ARGUMENTS

## Instructions

### Parse Input

Extract the user request from `$ARGUMENTS`. Detect flags:
- `--dry-run` — dispatch real workers but append `--dry-run` to each prompt so workers plan instead of write
- `--interactive` — pause after each phase for user review

### Load Workflow

Read `.claude/workflows/mean-app.yaml`. This YAML defines the pipeline: phases (name, agent, input, output, validation, depends_on), error handling, and context schema.

If the file doesn't exist, error: "No workflow configured. Run `/architect build` to create one."

### Execute Pipeline

For each phase defined in the workflow YAML, in dependency order:

1. **Create Task** — Use TaskCreate for this phase (subject = phase name, activeForm = "Running {phase name}")
2. **Mark in_progress** — Update the task status
3. **Build Prompt** — Construct the worker's prompt:
   - Include the original `user_request`
   - Include outputs from previous phases that this phase's `input` field lists
   - If `--dry-run`, append `--dry-run` to the prompt
   - For the acceptance-review phase (final PM invocation), add `--review` flag to trigger review mode
4. **Dispatch Worker** — Use the Task tool:
   ```
   Task(subagent_type="{agent-name-from-yaml}", prompt="{constructed prompt}", description="{phase name}")
   ```
5. **Collect Output** — The Task tool returns the worker's output
6. **Validate Gate** — Check the `validation` field from YAML against the worker's output
7. **Handle Result:**
   - Gate PASSES → mark task completed, store output for next phase
   - Gate FAILS → retry up to 2 times. If still failing, ask user: retry, skip, or abort

### Review Loop (Phase 6: code-review)

The code-review phase has special loop behavior:

1. Dispatch `reviewer-mean` with all context (backend + frontend summaries + architect designs)
2. Parse the reviewer's output for the JSON verdict block
3. If verdict = **PASS** → continue to testing phases
4. If verdict = **FAIL**:
   a. Extract `backend_issues` and `frontend_issues` from the verdict
   b. If `backend_issues` has critical items → re-dispatch `backend-mean` with the review feedback
   c. If `frontend_issues` has critical items → re-dispatch `frontend-mean` with the review feedback
   d. Re-dispatch `reviewer-mean` for second review
   e. Maximum 2 loop iterations — after 2 fails, escalate to user with remaining issues

### Parallel Phases

Phases 7 (backend-testing) and 8 (frontend-testing) can run in parallel since they have no dependency on each other — both depend only on code-review. Dispatch both using Task tool in the same message.

### Context Handoff

Each phase's prompt must include:
- The original `user_request` (always)
- Outputs from previous phases that this phase's `input` field lists in the YAML
- Only pass what the YAML says — do NOT pass "everything"

### Final Report

After all phases complete (or if the pipeline stops early), present:

```markdown
## Pipeline Complete: MEAN App

### Phase Results
| Phase | Agent | Status | Key Output |
|-------|-------|--------|------------|
| 0. Requirements | pm-mean | ✅ | PRD with X features |
| 1. DB Architecture | db-architect-mean | ✅ | X collections designed |
| 2. API Architecture | api-architect-mean | ✅ | X endpoints designed |
| 3. React Architecture | react-architect-mean | ✅ | X pages, X components |
| 4. Backend | backend-mean | ✅ | X files created |
| 5. Frontend | frontend-mean | ✅ | X files created |
| 6. Code Review | reviewer-mean | ✅ | PASS |
| 7. Backend Tests | qa-backend-mean | ✅ | X/Y tests passing |
| 8. Frontend Tests | qa-frontend-mean | ✅ | X/Y tests passing |
| 9. Acceptance | pm-mean | ✅ | PASS — X/X features verified |

### Deliverables
- [list of key files/directories created]

### Next Steps
- [recommendations from PM acceptance review]
```

### Critical Rules

NEVER read worker agent `.md` files (`.claude/agents/*.md`). You do not need to understand what workers do internally. You only need to invoke them via Task tool using the agent name from the workflow YAML and collect their output.

NEVER describe, plan, or execute what a worker would do. You are the dispatcher. Workers are autonomous — they have their own skills and instructions. Your job is: invoke, collect, validate, pass forward.

NEVER skip validation gates between phases.

ALWAYS use TaskCreate to track each phase as a task.

ALWAYS dispatch workers using the Task tool — this spawns a real subagent with its own context window.

NEVER do the workers' job yourself. If a worker fails, retry or escalate — don't try to do their work.
