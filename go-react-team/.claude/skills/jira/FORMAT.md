# Output Format

This file defines the structured output that agents using the Jira skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Output by Operation Type

### 1. Create Issue

**Single issue:**
```
Created: [KEY-123] Add user authentication endpoint — https://yourorg.atlassian.net/browse/KEY-123
```

**Multiple issues (batch):**
```
Created 4 issues:

| Key | Type | Summary | Parent |
|-----|------|---------|--------|
| [PROJ-100] | Epic | User Authentication | — |
| [PROJ-101] | Story | Implement login flow | PROJ-100 |
| [PROJ-102] | Sub-task | Backend: POST /auth/login | PROJ-101 |
| [PROJ-103] | Sub-task | Frontend: Login form component | PROJ-101 |
```

### 2. Update Issue

```
Updated: [KEY-123] Fields changed: priority (Medium → High), labels (+urgent), assignee (→ jane.doe)
```

When updating multiple fields, list all changed fields with before/after values where available.

### 3. Add Comment

```
Commented on [KEY-123]: "BLOCKED — waiting on KEY-456 for API schema finalization."
```

### 4. Link Issues

```
Linked: [KEY-123] blocks [KEY-456]
```

For multiple links:
```
Linked 3 issues:
- [KEY-100] blocks [KEY-101]
- [KEY-100] blocks [KEY-102]
- [KEY-103] relates to [KEY-100]
```

### 5. Transition Issue

```
Transitioned: [KEY-123] To Do → In Progress
```

### 6. Search Results

```
Found 5 issues matching: project = PROJ AND status = "In Progress"

| Key | Type | Priority | Summary | Assignee | Status |
|-----|------|----------|---------|----------|--------|
| [PROJ-101] | Story | High | Implement login flow | jane.doe | In Progress |
| [PROJ-108] | Bug | Highest | Login fails with special chars | john.doe | In Progress |
| [PROJ-112] | Task | Medium | Set up CI pipeline | — | In Progress |
| [PROJ-115] | Story | Medium | Add password reset | jane.doe | In Progress |
| [PROJ-119] | Sub-task | Low | Write unit tests for auth | alex.kim | In Progress |
```

When no results: `No issues found matching: [JQL query]`

### 7. Get Issue Details

```
[KEY-123] Implement login flow
  Type: Story | Priority: High | Status: In Progress
  Assignee: jane.doe | Sprint: Sprint 14
  Epic: [KEY-100] User Authentication
  Labels: backend, auth | Components: auth-service
  Story Points: 5
  Created: 2025-03-15 | Updated: 2025-03-18
  URL: https://yourorg.atlassian.net/browse/KEY-123

  Sub-tasks:
  - [KEY-124] Backend: POST /auth/login (In Progress)
  - [KEY-125] Frontend: Login form component (To Do)
  - [KEY-126] Write integration tests (To Do)

  Links:
  - blocks [KEY-130] Session management
  - relates to [KEY-98] OAuth provider setup
```

### 8. Error

```
[ERROR] Failed to create issue: Field 'component' value 'auth' not found in project PROJ.
  Available components: auth-service, web-app, api-gateway, shared-lib
  Suggestion: Did you mean 'auth-service'?
```

```
[ERROR] Issue KEY-999 not found. Verify the issue key and project access.
```

```
[ERROR] Transition 'Done' not available from current state 'To Do'.
  Available transitions: In Progress
  Suggestion: Transition to 'In Progress' first, then to 'Done'.
```

## Quality Checklist

After every Jira operation, verify:

```markdown
- [ ] Issue key present in output (e.g., [PROJ-123])
- [ ] URL included for created/updated issues
- [ ] Summary under 80 characters, imperative mood
- [ ] Description follows template (Story or Bug)
- [ ] Priority explicitly set (not left as default)
- [ ] Labels and components populated where applicable
- [ ] Parent Epic linked for Stories/Tasks/Bugs
- [ ] Sub-tasks created for Stories >3 days effort
- [ ] Related issues linked (blocks, relates to)
- [ ] No duplicate issues (searched before creating)
```

## Dry-Run Output Format

When `--dry-run` is active, prefix every action line with `[DRY RUN]`:

```
[DRY RUN] Would create: Story in PROJ — "Add user authentication endpoint"
  Fields: priority=High, labels=[backend, auth], components=[auth-service]
  Description: (154 chars, Story template)
  Epic Link: PROJ-100

[DRY RUN] Would create: Sub-task under PROJ-??? — "Backend: POST /auth/login"
[DRY RUN] Would create: Sub-task under PROJ-??? — "Frontend: Login form component"
[DRY RUN] Would link: PROJ-??? blocks PROJ-130
```

## Output Example (Complete Feature Workflow)

```
## Jira: Feature Ticket Creation

Created 4 issues:

| Key | Type | Summary | Parent |
|-----|------|---------|--------|
| [PROJ-200] | Epic | User Authentication System | — |
| [PROJ-201] | Story | Implement email/password login | PROJ-200 |
| [PROJ-202] | Sub-task | Backend: POST /auth/login endpoint | PROJ-201 |
| [PROJ-203] | Sub-task | Frontend: Login form with validation | PROJ-201 |

Linked 1 issue:
- [PROJ-201] relates to [PROJ-150]

Commented on [PROJ-201]: "Created from PRD section 3.1 — Authentication Requirements."

### Quality Checklist
- [x] Issue keys present
- [x] Summaries <80 chars, imperative mood
- [x] Story description follows template
- [x] Priority set to High
- [x] Labels: backend, frontend, auth
- [x] Epic link set
- [x] Sub-tasks created for decomposition
- [x] Related issues linked
- [x] No duplicates found (searched: summary ~ "login" AND project = PROJ)
```
