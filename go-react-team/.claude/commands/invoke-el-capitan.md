# /invoke-el-capitan

Internal delegation endpoint for worker agents to report results back to the el-capitan orchestrator.

## Context

$ARGUMENTS

## Instructions

This command is invoked by worker agents as their final task. It signals that the worker has completed its work and is ready to hand off results.

### What This Command Does

When a worker agent finishes, it calls this command with its results. The results are passed back to the el-capitan orchestrator through the Task tool return value.

### Expected Input Format

Workers should include in their delegation:
- **What was accomplished**: Summary of work done
- **Outputs produced**: Files created, reports generated, etc.
- **Issues encountered**: Any problems, warnings, or blockers
- **Recommendations for next phase**: Suggestions for downstream agents

### Processing

1. Acknowledge the worker's completion
2. Format the results for the orchestrator
3. Return the structured output via the Task tool return value

This is a passthrough — the worker's output becomes the phase's output in the pipeline.
