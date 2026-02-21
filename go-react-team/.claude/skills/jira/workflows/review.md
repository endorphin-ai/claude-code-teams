# Workflow: Search and Review Tickets

Use this playbook when searching, auditing, or reviewing Jira tickets — for sprint reviews, backlog grooming, blocked work audits, or ad-hoc queries.

## Steps

### 1. Determine the Review Type

Identify which review pattern applies:

| Review Type | Trigger | Goal |
|-------------|---------|------|
| **Sprint Review** | End of sprint | Summarize completed, incomplete, and carried-over work |
| **Backlog Grooming** | Planning prep | Identify stale, unestimated, or poorly defined tickets |
| **Blocked Work Audit** | Standup / escalation | Find and report all blocked issues with their blockers |
| **Ad-Hoc Query** | User request | Answer a specific question about the state of issues |
| **Duplicate Audit** | Periodic hygiene | Find and merge duplicate tickets |
| **Priority Review** | Triage meeting | Review and adjust priorities across the backlog |

### 2. Build the JQL Query

Use the patterns below based on the review type. Always confirm the project key and any filters before executing.

### 3. Execute the Search

Call `jira_search` with the JQL query. Request relevant fields:

```
fields: ["key", "summary", "issuetype", "priority", "status", "assignee", "created", "updated", "labels", "components", "story_points"]
```

Adjust `max_results` based on expected volume. Default to 50. For audits, set higher (200).

### 4. Analyze and Report

Present results in the table format defined in FORMAT.md. Add analysis and recommendations per the review type.

### 5. Delegate to El-Capitan

If running in a pipeline, hand off results to the next phase.

---

## Common Query Patterns

### Sprint Review

**Completed this sprint:**
```jql
project = {PROJECT} AND sprint in openSprints() AND status = Done ORDER BY issuetype ASC
```

**Incomplete / carried over:**
```jql
project = {PROJECT} AND sprint in openSprints() AND status != Done ORDER BY priority ASC
```

**Sprint velocity (story points completed):**
```jql
project = {PROJECT} AND sprint in openSprints() AND status = Done AND story_points > 0
```

**Report format:**
```
## Sprint Review: Sprint {N}

### Completed (X issues, Y story points)

| Key | Type | Priority | Summary | Assignee | Points |
|-----|------|----------|---------|----------|--------|
| ... | ... | ... | ... | ... | ... |

### Incomplete (X issues, Y story points remaining)

| Key | Type | Priority | Summary | Assignee | Status | Points |
|-----|------|----------|---------|----------|--------|--------|
| ... | ... | ... | ... | ... | ... | ... |

### Sprint Metrics
- Planned: {N} issues, {N} points
- Completed: {N} issues, {N} points
- Completion rate: {N}%
- Carried over: {N} issues, {N} points
```

---

### Backlog Grooming

**Unestimated issues in upcoming sprint or backlog:**
```jql
project = {PROJECT} AND issuetype in (Story, Task) AND (story_points is EMPTY OR story_points = 0) AND status = "To Do" ORDER BY priority ASC
```

**Stale tickets (no update in 30+ days, still open):**
```jql
project = {PROJECT} AND status not in (Done) AND updated <= -30d ORDER BY updated ASC
```

**Issues without assignee in active sprint:**
```jql
project = {PROJECT} AND sprint in openSprints() AND assignee is EMPTY AND status != Done
```

**Issues without Epic:**
```jql
project = {PROJECT} AND issuetype in (Story, Task, Bug) AND "Epic Link" is EMPTY AND status != Done
```

**Issues missing description:**
```jql
project = {PROJECT} AND description is EMPTY AND status != Done AND issuetype in (Story, Bug)
```

**Report format:**
```
## Backlog Grooming Report

### Unestimated Issues ({N} found)

| Key | Type | Priority | Summary | Created |
|-----|------|----------|---------|---------|
| ... | ... | ... | ... | ... |

[WARN] {N} issues in the upcoming sprint have no estimates.

### Stale Issues ({N} found, no update in 30+ days)

| Key | Type | Summary | Last Updated | Assignee |
|-----|------|---------|-------------|----------|
| ... | ... | ... | ... | ... |

Recommendation: Review these for relevance. Close or re-prioritize.

### Missing Fields ({N} issues)
- {N} without assignee in active sprint
- {N} without Epic link
- {N} without description (Stories/Bugs)

### Grooming Actions Needed
1. Estimate {N} unestimated issues before sprint planning
2. Triage {N} stale issues — close or update
3. Assign {N} unassigned issues in active sprint
4. Link {N} orphan issues to Epics
```

---

### Blocked Work Audit

**All blocked issues:**
```jql
project = {PROJECT} AND status != Done AND issuefunction in hasLinks("is blocked by")
```

If `issuefunction` is not available, use a two-step approach:
1. Search for issues with `Blocks` link type via the API
2. Cross-reference to find blocked issues

**Issues in "In Progress" for too long (possible hidden blockers):**
```jql
project = {PROJECT} AND status = "In Progress" AND updated <= -7d
```

**Report format:**
```
## Blocked Work Audit

### Explicitly Blocked ({N} issues)

| Key | Summary | Blocked By | Blocker Status | Days Blocked |
|-----|---------|------------|---------------|-------------|
| [PROJ-108] | Login fails with special chars | [PROJ-95] | In Progress | 5 |
| [PROJ-115] | Add password reset | [PROJ-112] | To Do | 12 |

[WARN] [PROJ-115] has been blocked for 12 days. Blocker [PROJ-112] is still in To Do.

### Possibly Stuck ({N} issues — In Progress >7 days with no update)

| Key | Summary | Assignee | Last Updated | Days Since Update |
|-----|---------|----------|-------------|-------------------|
| ... | ... | ... | ... | ... |

### Recommendations
1. Escalate [PROJ-112] — blocking downstream work for 12 days
2. Check in on {N} stale In Progress issues
3. Total blocked story points: {N}
```

---

### Ad-Hoc Query Patterns

**All bugs by priority:**
```jql
project = {PROJECT} AND issuetype = Bug AND status != Done ORDER BY priority ASC, created DESC
```

**Work by a specific assignee:**
```jql
project = {PROJECT} AND assignee = "{username}" AND status != Done ORDER BY priority ASC
```

**Recently created issues (last 7 days):**
```jql
project = {PROJECT} AND created >= -7d ORDER BY created DESC
```

**Issues with a specific label:**
```jql
project = {PROJECT} AND labels = "{label}" AND status != Done ORDER BY priority ASC
```

**Issues transitioned to Done this week:**
```jql
project = {PROJECT} AND status changed TO Done AFTER startOfWeek()
```

**Epics with their completion status:**
```jql
project = {PROJECT} AND issuetype = Epic AND status != Done ORDER BY priority ASC
```
Then for each Epic, query children:
```jql
"Epic Link" = {EPIC_KEY}
```

**Issues by component:**
```jql
project = {PROJECT} AND component = "{component}" AND status != Done ORDER BY priority ASC
```

---

### Duplicate Audit

**Potential duplicates (same keywords in summary):**
```jql
project = {PROJECT} AND issuetype = Bug AND status != Done AND summary ~ "{keyword}" ORDER BY created ASC
```

Run this for common symptom keywords. Group results by similarity.

**Report format:**
```
## Duplicate Audit

### Potential Duplicate Groups

**Group 1: Login failures ({N} tickets)**
| Key | Summary | Created | Status |
|-----|---------|---------|--------|
| [PROJ-108] | Login fails with special characters | 2025-03-10 | In Progress |
| [PROJ-145] | Login error with + in email | 2025-03-15 | To Do |

Recommendation: [PROJ-145] likely duplicates [PROJ-108]. Link and close [PROJ-145].

**Group 2: ...**
```

---

### Priority Review

**All open issues sorted by priority:**
```jql
project = {PROJECT} AND status != Done ORDER BY priority ASC, issuetype ASC, created ASC
```

**High/Highest priority issues not in sprint:**
```jql
project = {PROJECT} AND priority in (Highest, High) AND status != Done AND sprint not in openSprints()
```

**Report format:**
```
## Priority Review

### High-Priority Issues Not in Sprint ({N} found)

| Key | Type | Priority | Summary | Created | Days Open |
|-----|------|----------|---------|---------|-----------|
| ... | ... | ... | ... | ... | ... |

[WARN] {N} High/Highest priority issues are not scheduled in any sprint.

### Priority Distribution (Open Issues)
- Highest: {N}
- High: {N}
- Medium: {N}
- Low: {N}
- Lowest: {N}

### Recommendations
1. Schedule {N} unscheduled high-priority issues
2. Review {N} Highest-priority issues older than 14 days
```

---

## Search Best Practices

1. **Always show the JQL query** — makes it reproducible and auditable.
2. **Request only needed fields** — faster responses, less noise.
3. **Set appropriate max_results** — 50 for targeted queries, 200 for audits.
4. **Sort intentionally** — priority ASC puts Highest first; created DESC puts newest first.
5. **Count before detail** — "Found 12 issues" before the table.
6. **Flag anomalies** — stale high-priority items, unassigned sprint work, long-blocked issues.
7. **Provide actionable recommendations** — don't just report, suggest next steps.
8. **Use relative dates** — `-7d`, `-30d`, `startOfWeek()` instead of hardcoded dates.

## Checklist

- [ ] Review type identified
- [ ] JQL query shown in output
- [ ] Results in table format per FORMAT.md
- [ ] Count/summary provided before details
- [ ] Anomalies flagged with [WARN]
- [ ] Actionable recommendations included
- [ ] Output matches FORMAT.md
