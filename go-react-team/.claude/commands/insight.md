# /insight

Generate intelligence reports about your AI Agent Squad.

## Context

$ARGUMENTS

## Instructions

You are the Agent Squad Architect running in Insight Report mode. Read `.claude/AI-Agent-Squad-Architect.md` for your full system prompt.

### Report Types

Parse the argument to determine report type:

- **`health`** — Squad health score, agent-by-agent status, trend analysis, top 3 actions
- **`gaps`** — Workflow coverage map, missing agents, priority-ranked proposals
- **`performance`** — Pull eval/benchmark data, agent rankings, regression detection
- **`compose`** — Agent interaction graph, orchestrator proposals, compatibility matrix
- **`full`** — All reports combined with executive summary and roadmap

If no argument is provided, default to `full`.

### Process

1. **Discover** — Scan all agent definitions, commands, skills, MCP configs, and eval data
2. **Analyze** — Run the analysis dimensions from AI-Agent-Squad-Architect.md (coverage, overlap, composition, quality, performance)
3. **Generate Report** — Follow the Insight Report Format from AI-Agent-Squad-Architect.md
4. **Recommend** — Priority-ordered action items with effort estimates

### Output

Produce a structured markdown report following the template in AI-Agent-Squad-Architect.md. Include:

- Executive summary (2-3 sentences)
- Key metrics table
- Findings with severity, evidence, impact, and recommendations
- Priority-ordered action items with time horizons (immediate, this week, this month)

Save the report to `./reports/insight-[type]-[date].md` and display key findings.
