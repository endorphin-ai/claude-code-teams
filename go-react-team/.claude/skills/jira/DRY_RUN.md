# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill builds the full Jira payload
and validates all fields, but does NOT call mutating MCP tools. Search queries are
safe and execute normally.

## What IS Executed (Safe / Read-Only)

- `jira_search` — JQL queries run normally. Searching is non-destructive.
- `jira_get_issue` — Reading issue details runs normally.
- Duplicate detection queries — these are searches and execute as usual.
- Field validation — verify project keys, issue types, components, and labels exist.
- JQL syntax validation — confirm queries parse correctly by running them.

## What is NOT Executed (Mutating Operations)

- `jira_create_issue` — Show the full payload that would be sent.
- `jira_update_issue` — Show the fields that would change with before/after values.
- `jira_add_comment` — Show the comment body that would be posted.
- `jira_link_issues` — Show the link that would be created.
- `jira_transition_issue` — Show the state transition that would occur.

## Output Format

Every blocked action is prefixed with `[DRY RUN]` and shows the complete payload:

### Create Issue Preview

```
[DRY RUN] Would create issue:
  Project: PROJ
  Type: Story
  Summary: Add user authentication endpoint
  Priority: High
  Labels: [backend, auth]
  Components: [auth-service]
  Epic Link: PROJ-100
  Description: (178 chars, Story template)
  ---
  Full payload:
  {
    "project": "PROJ",
    "issuetype": "Story",
    "summary": "Add user authentication endpoint",
    "priority": "High",
    "labels": ["backend", "auth"],
    "components": ["auth-service"],
    "description": "h2. User Story\nAs a developer, I want..."
  }
```

### Update Issue Preview

```
[DRY RUN] Would update [PROJ-123]:
  priority: Medium → High
  labels: [backend] → [backend, urgent]
  assignee: (unassigned) → jane.doe
```

### Comment Preview

```
[DRY RUN] Would comment on [PROJ-123]:
  Body: "BLOCKED — waiting on PROJ-456 for API schema finalization."
```

### Link Preview

```
[DRY RUN] Would link: [PROJ-123] blocks [PROJ-456]
  Link type: Blocks
  Inward: PROJ-456 (is blocked by)
  Outward: PROJ-123 (blocks)
```

### Transition Preview

```
[DRY RUN] Would transition [PROJ-123]: To Do → In Progress
```

### Batch Preview

```
[DRY RUN] Summary — 6 operations planned:

| # | Operation | Target | Details |
|---|-----------|--------|---------|
| 1 | Create | Epic | "User Authentication System" in PROJ |
| 2 | Create | Story | "Implement login flow" under Epic #1 |
| 3 | Create | Sub-task | "Backend: POST /auth/login" under Story #2 |
| 4 | Create | Sub-task | "Frontend: Login form" under Story #2 |
| 5 | Link | — | Story #2 relates to [PROJ-150] |
| 6 | Comment | Story #2 | "Created from PRD section 3.1" |

[DRY RUN] Search results (LIVE — read-only queries executed):
Found 0 potential duplicates for: summary ~ "login" AND project = PROJ AND status != Done
→ Safe to proceed with creation.
```

## What to Validate During Dry Run

Even without executing mutations, perform these real checks:

1. **Project exists** — Confirm the project key is valid via a search query.
2. **Issue types available** — Verify the issue type is configured for the target project.
3. **Components/labels exist** — Search for existing components; warn if a new one would be implicitly created.
4. **Duplicate detection** — Run the same duplicate-detection JQL you would in a live run.
5. **Parent issue exists** — For Sub-tasks, verify the parent Story/Task key is real and in the right state.
6. **Assignee exists** — If an assignee is specified, verify the account exists.
7. **Transition validity** — Check if the target state is reachable from the current state.

## What NOT to Do

- DO NOT call `jira_create_issue`, `jira_update_issue`, `jira_add_comment`, `jira_link_issues`, or `jira_transition_issue`.
- DO NOT skip payload construction — build the exact same payload you would in a live run.
- DO NOT skip validation — dry run should catch errors before they happen in production.
- DO still run all search/read queries. They are safe and provide real validation data.
- DO still follow FORMAT.md structure, but prefix all mutation outputs with `[DRY RUN]`.
