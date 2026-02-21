# /jira-update

Update fields on an existing Jira ticket using the Atlassian MCP server.

## Context

$ARGUMENTS

## Instructions

### Purpose

Update one or more fields on an existing Jira issue.

### Process

1. **Read Skill Knowledge** — Load `.claude/skills/jira/SKILL.md` and `.claude/skills/jira/FORMAT.md`.

2. **Parse Arguments** — Extract from `$ARGUMENTS`:
   - First positional argument: Issue key (e.g., FULL-123). Required.
   - `--status` or `-s`: New status (e.g., "In Progress", "In Review", "Done")
   - `--priority` or `-p`: New priority
   - `--assignee` or `-a`: New assignee
   - `--summary`: New summary
   - `--description` or `-d`: New description
   - `--labels`: Labels to set (comma-separated)
   - `--sprint`: Sprint name or ID
   - `--points`: Story points
   - If no flags, parse natural language (e.g., "move FULL-123 to In Progress")

3. **Validate** — Ensure issue key is provided. If missing, ask the user.

4. **Update Issue** — Use the Atlassian MCP `jira_update_issue` tool with the parsed fields.

5. **Report** — Output:
   ```
   Updated: [FULL-123] Fields changed: status → In Progress, priority → High — URL
   ```

### Edge Cases

- If issue key doesn't exist: show error with suggestion to search
- If status transition is invalid: show valid transitions for current status
- If multiple fields updated: report all changed fields
