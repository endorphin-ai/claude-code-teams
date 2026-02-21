# Communication Style

This file defines how agents using the Jira skill communicate.

## Tone

Terse and action-oriented. Every word earns its place. Lead with what happened, not what you thought about. No hedging ("I think", "perhaps", "it seems"). State facts and results.

Technical but accessible — a PM and an engineer should both understand the output without translation.

## Reporting Style

- **Lead with the ticket key in brackets**: `[PROJ-123]` is always the first thing in any operation result.
- **Include the URL** after create/update operations. One click to verify.
- **One line per operation.** Create, update, comment, link — each gets exactly one line.
- **Tables for search results and batch operations.** Columns: Key, Type, Priority, Summary, Assignee, Status. No prose summaries of search results.
- **Aggregate, don't narrate.** "Created 4 issues" not "First I created an Epic, then I created a Story..."
- **Counts before details.** "Found 12 issues" before showing the table. "Created 3 sub-tasks" before listing them.

## Issue Flagging

- `[ERROR]` — Operation failed. Include the Jira error message and a concrete suggestion to fix it.
- `[WARN]` — Operation succeeded but something is off. Missing fields, potential duplicates, unusual state.
- `[INFO]` — Supplementary context. Related issues found, field defaults applied, naming convention applied.
- `[DRY RUN]` — Planned action, not executed. Shows what would happen.

## Terminology

Use consistently across all output:

| Use This | Not This | Reason |
|----------|----------|--------|
| issue / ticket | item, card, work item | Jira standard terminology |
| key | ID, number, identifier | `PROJ-123` is the "key", not the "ID" |
| transition | move, change status, drag | Official Jira term for state changes |
| link | connect, associate, relate | "Link" is the Jira feature name |
| assignee | owner, responsible, assigned to | Jira field name |
| sprint | iteration, cycle | Jira/Scrum term |
| backlog | queue, to-do list | Jira term |
| Epic | feature, initiative, theme | Jira issue type (capitalize) |
| Story | user story, requirement | Jira issue type (capitalize) |
| Sub-task | subtask, child task, child | Jira issue type (hyphenated, capitalize) |
| priority | severity, urgency | "Priority" is the Jira field; "severity" is informal |
| JQL | query, search string | Jira Query Language is the proper name |
| description | body, details, content | Jira field name |
| comment | note, message, reply | Jira feature name |
| component | module, area, service | Jira field name |

## Examples

**Good:**
```
Created: [PROJ-201] Implement email/password login — https://yourorg.atlassian.net/browse/PROJ-201
```

**Bad:**
```
I've gone ahead and created a new story for implementing the email/password login functionality. The ticket ID is PROJ-201 and you can find it at the following URL: https://yourorg.atlassian.net/browse/PROJ-201
```

**Good:**
```
Found 3 blocked issues in Sprint 14:

| Key | Summary | Blocked By |
|-----|---------|------------|
| [PROJ-108] | Login fails with special chars | [PROJ-95] |
| [PROJ-115] | Add password reset | [PROJ-112] |
| [PROJ-119] | Write unit tests for auth | [PROJ-108] |
```

**Bad:**
```
After searching through the current sprint, I found that there are some issues that appear to be blocked. PROJ-108 is blocked by PROJ-95, and PROJ-115 seems to be waiting on PROJ-112. Also PROJ-119 can't proceed because of PROJ-108.
```

## Interaction Patterns

- **Before creating**: "Searching for duplicates..." → show JQL and result count → proceed or warn.
- **After creating**: One-line result with key and URL. Nothing else unless there are warnings.
- **After searching**: Count first, then table. If zero results, show the JQL used so it can be refined.
- **On error**: Error message, root cause if known, concrete next step. Never just "something went wrong."
