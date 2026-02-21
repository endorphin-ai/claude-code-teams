# Workflow: Create Bug Tickets

Use this playbook when creating Jira tickets for bugs, defects, or regressions — whether reported by users, discovered in testing, or found during code review.

## Steps

### 1. Parse the Bug Report

Extract from the input:
- **Symptom** — what the user observes going wrong
- **Steps to reproduce** — how to trigger the bug
- **Expected behavior** — what should happen
- **Actual behavior** — what actually happens (error messages, status codes, screenshots)
- **Environment** — browser, OS, version, staging vs production
- **Frequency** — always, often, sometimes, rarely
- **Workaround** — does one exist?
- **Affected users** — scope of impact

If reproduction steps are missing or unclear, note this in the ticket description and add label `needs-repro`.

### 2. Assess Severity

Use the severity matrix to determine priority:

#### Severity Guide

| Priority | Impact | Frequency | Workaround | Examples |
|----------|--------|-----------|------------|----------|
| **Highest** (P0) | System down, data loss, security breach | Any | None | Production outage, auth bypass, data corruption |
| **High** (P1) | Core feature broken, significant UX degradation | Often / Always | None or painful | Login fails for subset of users, payments failing |
| **Medium** (P2) | Feature partially broken, non-critical path | Sometimes | Exists | Filter not working, export has wrong format |
| **Low** (P3) | Cosmetic, minor inconvenience | Rarely | Trivial | Typo in UI, misaligned button, wrong date format |
| **Lowest** (P4) | Edge case, negligible impact | Rarely | Not needed | Browser-specific rendering glitch on old version |

#### Severity Decision Tree

```
Is the system down or data at risk?
  → Yes: Highest (P0)
  → No: Continue

Is a core user flow broken?
  → Yes: Is there a workaround?
    → No: High (P1)
    → Painful workaround: High (P1)
    → Easy workaround: Medium (P2)
  → No: Continue

Is the issue cosmetic or edge-case only?
  → Cosmetic: Low (P3)
  → Edge case: Lowest (P4)
  → Neither: Medium (P2)
```

### 3. Search for Duplicates

Before creating, check for existing reports:

```jql
project = {PROJECT} AND issuetype = Bug AND status != Done AND summary ~ "{symptom keywords}"
```

Also check:
```jql
project = {PROJECT} AND issuetype = Bug AND status != Done AND description ~ "{error message}"
```

If a duplicate is found:
- **Exact duplicate**: Link as "duplicates" and add a comment to the existing ticket with any new information.
- **Related but different**: Create the new ticket and link as "relates to".
- **Same root cause**: Create if the symptom is different, link as "is caused by" if root cause ticket exists.

### 4. Identify Root Cause Context (if possible)

If the bug report includes enough information, note:
- **Likely component** — which service/module is affected
- **Recent changes** — any recent deployments or PRs that could have introduced this
- **Related tickets** — existing work in the same area

This goes into the "Technical Notes" section of the description, not as a definitive root cause analysis.

### 5. Create the Bug Ticket

Call `jira_create_issue` with:

**Summary**: State the symptom in imperative mood.
- Good: "Login fails with 500 when email contains special characters"
- Bad: "Login broken" or "Bug in authentication"

**Description**: Use the Bug template from SKILL.md:

```
h2. Summary
[One-sentence description of the defect]

h2. Steps to Reproduce
# [Step 1]
# [Step 2]
# [Step 3]

h2. Expected Behavior
[What should happen]

h2. Actual Behavior
[What actually happens — include error messages, status codes, stack traces]

h2. Environment
* Browser/OS/Device: [details]
* Version/Build: [details]
* Environment: [staging / production / local]

h2. Severity Assessment
* Impact: [Critical / High / Medium / Low]
* Frequency: [Always / Often / Sometimes / Rarely]
* Workaround: [None / Exists — describe]

h2. Technical Notes
* Likely component: [component name]
* Related recent changes: [PR #, deployment date]
* Related issues: [KEY-xxx]
```

**Fields**:
- `issuetype`: Bug
- `priority`: From severity assessment (Step 2)
- `labels`: Include `bug` + area labels. Add `needs-repro` if reproduction steps are unclear. Add `regression` if this previously worked.
- `components`: The affected system component
- `epic_link`: The feature area Epic, if identifiable

### 6. Link and Annotate

- **Link to related issues** — if this blocks other work, or is caused by a known issue
- **Link to duplicate** — if this is a known duplicate with new information
- **Add comment** — reference the source of the report (support ticket, Slack message, test run, monitoring alert)

### 7. Report Result

Output using FORMAT.md structure:

```
Created: [PROJ-300] Login fails with 500 when email contains special characters — https://yourorg.atlassian.net/browse/PROJ-300
  Type: Bug | Priority: High | Labels: [bug, auth, regression]
  Component: auth-service | Epic: [PROJ-100]
  Severity: P1 — Core flow broken, no workaround, affects 15% of users

Linked: [PROJ-300] relates to [PROJ-201]
Commented on [PROJ-300]: "Reported via support ticket #4521. First observed after deploy v2.3.1 (2025-03-18)."
```

Then delegate to el-capitan if running in a pipeline.

## Triage Patterns

### Production Incident (P0/P1)

1. Create Bug with Highest/High priority immediately
2. Add label `production-incident`
3. Assign to on-call engineer if known
4. Transition to "In Progress" immediately
5. Link to any related monitoring alerts or incident tickets
6. Add comment: "PRODUCTION INCIDENT — [impact summary]. Investigate immediately."

### Regression

1. Search for the original issue that this regresses
2. Create Bug with label `regression`
3. Link to the original issue with "relates to"
4. Reference the PR/deploy that likely introduced it
5. Priority: minimum High (regressions are always at least P1)

### User-Reported Bug

1. Create Bug with information available
2. Add label `user-reported`
3. If reproduction steps are unclear, add `needs-repro`
4. Add comment with source reference (support ticket number, user email — no PII in public comments)

### Test Failure Bug

1. Create Bug with label `test-failure`
2. Include the test name, test suite, and failure output in description
3. Link to the Story/Task whose test is failing
4. Priority: at least Medium (broken tests block CI)

## Checklist

- [ ] Symptom clearly stated in summary
- [ ] Severity assessed using the matrix
- [ ] Priority set to match severity assessment
- [ ] Description follows Bug template
- [ ] Steps to reproduce included (or `needs-repro` label added)
- [ ] Expected vs actual behavior documented
- [ ] Environment specified
- [ ] Duplicates checked before creation
- [ ] Labels include `bug` + area labels
- [ ] Component assigned
- [ ] Related issues linked
- [ ] Source of report noted in comment
- [ ] Output matches FORMAT.md
