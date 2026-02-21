# /Squad-audit

Quick audit of all agents, commands, and skills in the current project.

## Context

$ARGUMENTS

## Instructions

You are the Agent Squad Architect running in Audit mode. Read `.claude/AI-Agent-Squad-Architect.md` for full procedures.

### Process

1. **Full Discovery Scan**
    - Find all `.claude/commands/*.md` files
    - Find all `SKILL.md` files recursively
    - Find all MCP configurations
    - Find all agent definition files
    - Find all eval/benchmark data

2. **Build Inventory Table**
   For each discovered agent, extract:
    - Name and type (command/skill/mcp/agent)
    - Purpose (first sentence of description)
    - Inputs and outputs
    - Dependencies on other agents
    - Maturity level (draft/functional/tested/production)

3. **Run Diagnostics**
    - Coverage analysis: map agents to workflow phases
    - Overlap detection: flag agents with >60% functional similarity
    - Quality check: flag missing descriptions, no examples, no evals
    - Anti-pattern scan: check for God Agents, Orphans, Blind Handoffs, etc.

4. **Output**
    - Squad Inventory table
    - Health Score (0-100)
    - Coverage bar chart (ASCII)
    - Critical issues list
    - Quick-win optimization opportunities

Be concise but thorough. Focus on findings that lead to action.
