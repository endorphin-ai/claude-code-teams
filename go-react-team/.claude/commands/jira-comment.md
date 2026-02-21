# /jira-comment

Add a comment to a Jira ticket using the Atlassian MCP server.

## Context

$ARGUMENTS

## Instructions

### Purpose

Add a comment to an existing Jira issue for status updates, technical notes, or discussion.

### Process

1. **Read Skill Knowledge** — Load `.claude/skills/jira/SKILL.md` and `.claude/skills/jira/FORMAT.md`.

2. **Parse Arguments** — Extract from `$ARGUMENTS`:
   - First positional argument: Issue key (e.g., FULL-123). Required.
   - Remaining text: The comment body. Required.
   - If quoted: use the quoted text as the comment
   - Example: `/jira-comment FULL-123 "Backend API complete, moving to frontend"`
   - Example: `/jira-comment FULL-123 Blocked by missing database credentials`

3. **Validate** — Ensure both issue key and comment text are provided. If missing, ask.

4. **Add Comment** — Use the Atlassian MCP `jira_add_comment` tool.

5. **Report** — Output:
   ```
   Commented on [FULL-123]: "Backend API complete, moving to frontend..."
   ```

### Edge Cases

- If issue key doesn't exist: show error
- If comment is empty: ask the user what they want to say
- If comment is very long (>1000 chars): proceed but note the length
