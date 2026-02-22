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

This is a delegation endpoint — the actual orchestration logic lives in `/el-capitan`.
