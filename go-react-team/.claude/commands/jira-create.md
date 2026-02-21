# /jira-create

Create a new Jira ticket using the Atlassian MCP server.

## Context

$ARGUMENTS

## Instructions

### Purpose

Create a Jira issue (Story, Task, Bug, Epic, or Sub-task) with structured fields.

### Process

1. **Read Skill Knowledge** — Load `.claude/skills/jira/SKILL.md` for Jira conventions and `.claude/skills/jira/FORMAT.md` for output format.

2. **Parse Arguments** — Extract from `$ARGUMENTS`:
   - `--type` or `-t`: Issue type (story, task, bug, epic, subtask). Default: story
   - `--project` or `-p`: Project key (e.g., FULL). Required.
   - `--summary` or `-s`: Issue summary. Required.
   - `--description` or `-d`: Issue description. Optional.
   - `--priority`: Priority (highest, high, medium, low, lowest). Default: medium
   - `--labels`: Comma-separated labels. Optional.
   - `--assignee`: Assignee username. Optional.
   - `--parent`: Parent issue key for sub-tasks or stories under epics. Optional.
   - If no flags provided, parse the natural language input to extract these fields.

3. **Validate** — Ensure project and summary are provided. If missing, ask the user.

4. **Create Issue** — Use the Atlassian MCP `jira_create_issue` tool with the parsed fields.

5. **Report** — Output in FORMAT.md format:
   ```
   Created: [KEY-123] Summary — URL
   Type: Story | Priority: Medium | Project: FULL
   ```

### Edge Cases

- If project key is unknown: list available projects using `jira_search` with JQL
- If issue type is invalid: show valid types and ask user to choose
- If MCP server is not configured: show error with setup instructions
