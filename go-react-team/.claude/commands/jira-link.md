# /jira-link

Link two Jira tickets using the Atlassian MCP server.

## Context

$ARGUMENTS

## Instructions

### Purpose

Create a link between two Jira issues to show relationships (blocks, relates to, duplicates, etc.).

### Process

1. **Read Skill Knowledge** — Load `.claude/skills/jira/SKILL.md` and `.claude/skills/jira/FORMAT.md`.

2. **Parse Arguments** — Extract from `$ARGUMENTS`:
   - First issue key: Source issue (e.g., FULL-123). Required.
   - Link type: One of: `blocks`, `is-blocked-by`, `relates-to`, `duplicates`, `is-duplicated-by`, `clones`, `is-cloned-by`. Required.
   - Second issue key: Target issue (e.g., FULL-456). Required.
   - Example: `/jira-link FULL-123 blocks FULL-456`
   - Example: `/jira-link FULL-100 relates-to FULL-200`

3. **Validate** — Ensure both issue keys and link type are provided. If missing, ask.

4. **Create Link** — Use the Atlassian MCP `jira_link_issues` tool with:
   - `inwardIssue`: source issue key
   - `outwardIssue`: target issue key
   - `linkType`: the relationship type

5. **Report** — Output:
   ```
   Linked: [FULL-123] blocks [FULL-456]
   ```

### Edge Cases

- If link type is invalid: show valid link types and ask user to choose
- If either issue key doesn't exist: show error
- If link already exists: note it and proceed (Jira handles duplicates)
- If user provides natural language (e.g., "FULL-123 is blocked by FULL-456"): parse accordingly
