# Workflow: Bug Fix PRD

Use this playbook when writing a PRD for a bug fix. Unlike feature PRDs, bug fix PRDs document a defect and define the criteria for a successful fix.

Bug fix PRDs are shorter and more targeted than feature PRDs, but they follow the same rigor: every fix must have testable acceptance criteria.

## Prerequisites

- A bug report from the user (can range from "X is broken" to a detailed report with reproduction steps)
- Access to the existing codebase to investigate the defect
- The original PRD (if one exists) to determine expected behavior

## Steps

### 1. Parse the Bug Report

Extract from the user's report:
- **What is broken** — the symptom the user observed
- **Where it occurs** — which feature, page, endpoint, or flow
- **When it occurs** — under what conditions (always? intermittently? after a specific action?)
- **Severity** — how badly does this affect users? (P0: system unusable, P1: feature broken but workaround exists, P2: cosmetic or minor annoyance)

If the user report is vague, investigate the codebase to gather more context before writing the PRD.

### 2. Investigate and Reproduce

Analyze the codebase to understand the defect:
- Read the relevant source files (handlers, components, services)
- Trace the code path that the bug report describes
- Identify the probable root cause or narrow it down to a specific area
- Check if this is a regression (did it work before?) by reviewing git history if relevant
- Check if the original PRD specifies the correct behavior

Document your findings. You do not need to identify the exact root cause (that is the developer's job), but you should narrow the scope enough that the developer knows where to look.

### 3. Define Expected vs. Actual Behavior

Write precise descriptions of:
- **Expected behavior** — what the system SHOULD do, based on the original PRD or reasonable user expectation. Use concrete values: "the endpoint should return HTTP 200 with `{ data: [...] }`"
- **Actual behavior** — what the system DOES do. Be specific: "the endpoint returns HTTP 500 with `{ error: 'null pointer' }`" not "the endpoint crashes"

### 4. Write Reproduction Steps

Document the steps to reproduce the bug:
1. Start each step with an action ("Navigate to...", "Submit form with...", "Send POST request to...")
2. Include specific test data where relevant
3. Note the environment conditions if relevant (authenticated vs. unauthenticated, specific data state)
4. End with the observable failure

### 5. Define Fix Acceptance Criteria

Write acceptance criteria that the fix must satisfy:

- **Primary fix criterion** — GIVEN the reproduction conditions, WHEN the action is performed, THEN the expected behavior occurs (not the bug)
- **Non-regression criteria** — GIVEN related normal usage, WHEN standard actions are performed, THEN existing functionality still works correctly
- **Edge case criteria** — if the bug involves an edge case, add criteria for adjacent edge cases that might have the same root cause

Minimum criteria for any bug fix PRD:
1. At least one criterion proving the bug is fixed
2. At least one criterion proving no regression in the affected feature
3. At least one criterion covering a related edge case

### 6. Assess Impact and Scope

Document:
- **Affected features** — list feature IDs from the original PRD if applicable
- **Affected files (suspected)** — list files that are likely involved (helps scope the developer's work)
- **Risk areas** — other features that share code paths with the bug and might be affected by the fix
- **Fix scope constraint** — explicitly state that the fix should be minimal and targeted. No refactoring, no new features, no unrelated changes.

### 7. Assemble the Bug Fix PRD

Write the complete bug fix PRD to `docs/prd-bugfix-{slug}.md` with this structure:

```markdown
# Bug Fix PRD: {Short Description}
**Bug ID:** BUG-{NNN}
**Severity:** P0 | P1 | P2
**Date:** {YYYY-MM-DD}
**Author:** pm-fullstack
**Status:** Draft | Approved
**Related PRD:** {path to original PRD, if applicable}

## Defect Description
{2-3 sentences describing the bug from the user's perspective.}

## Expected vs. Actual Behavior

### Expected
{What should happen. Be specific.}

### Actual
{What does happen. Be specific.}

## Reproduction Steps
1. {Step 1}
2. {Step 2}
3. {Step 3}
4. **Observed:** {The failure}

## Investigation Notes
{Summary of codebase investigation. Suspected root cause area. Relevant files.}

## Affected Features
- {F-XXX: Feature Name (from original PRD)}

## Fix Acceptance Criteria
- **AC-BUG-{NNN}-01:** GIVEN {reproduction conditions}, WHEN {action}, THEN {expected behavior, NOT the bug}.
- **AC-BUG-{NNN}-02:** GIVEN {normal usage of affected feature}, WHEN {standard action}, THEN {feature still works correctly (non-regression)}.
- **AC-BUG-{NNN}-03:** GIVEN {related edge case}, WHEN {action}, THEN {correct behavior}.

## Fix Scope
- **In scope:** {Only the minimal change to fix the defect}
- **Out of scope:** {Refactoring, new features, unrelated improvements}
- **Risk areas:** {Other features/code that shares the affected code path}

## Open Questions
- {Any questions that need answers before the fix can proceed}
```

### 8. Self-Review

Before reporting completion, verify:
- Expected and actual behavior are clearly distinct and specific
- Reproduction steps are detailed enough for a developer to follow
- Every acceptance criterion uses GIVEN/WHEN/THEN format
- At least one non-regression criterion exists
- Fix scope is explicitly constrained (minimal fix, no extras)
- The bug fix PRD follows the structure above exactly

### 9. Report to El-Capitan

Prepare the delegation message. Include:
- Mode: Phase 0 (Bug Fix PRD)
- Output file path
- Bug severity
- Affected features
- Number of acceptance criteria
- Recommendation for the developer

## Checklist

- [ ] Bug report fully parsed and understood
- [ ] Codebase investigated to narrow the defect scope
- [ ] Expected vs. actual behavior documented with specific values
- [ ] Reproduction steps written with concrete actions
- [ ] At least one fix criterion, one non-regression criterion, one edge case criterion
- [ ] All acceptance criteria use GIVEN/WHEN/THEN format
- [ ] Fix scope explicitly constrained to minimal change
- [ ] Impact assessment includes affected features and risk areas
- [ ] Bug fix PRD saved to `docs/prd-bugfix-{slug}.md`
- [ ] Delegation message prepared for el-capitan
