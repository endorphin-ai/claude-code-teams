# Workflow: Bug Investigation and Fix Review

Use this playbook when investigating a reported bug in a fullstack Go+React application and reviewing the proposed fix. The architect agent uses this workflow to analyze which architectural layer is affected, propose a fix approach, and review the fix for design conformance.

## Prerequisites

- Bug report exists with: description, steps to reproduce, expected vs actual behavior
- System design document exists (for conformance reference)
- Codebase is accessible for reading

## Steps

### 1. Analyze the Bug Context

Read the bug report and classify:

- **Symptom:** What the user or test observes (wrong data, error message, broken UI, etc.)
- **Expected behavior:** What should happen according to the PRD or design doc
- **Actual behavior:** What happens instead
- **Reproduction path:** Sequence of actions that triggers the bug

Map the symptom to a system layer:

```
+---------------------+----------------------------------------+
| Symptom Pattern     | Likely Layer                           |
+---------------------+----------------------------------------+
| Wrong data shown    | Repository (bad query) or Service      |
|                     | (bad transformation)                   |
| 500 error           | Handler (missing error case) or        |
|                     | Service (unhandled edge case)          |
| 400/422 error       | DTO validation (too strict or missing) |
| 404 when exists     | Router (wrong path) or Repository      |
|                     | (wrong WHERE clause)                   |
| UI not rendering    | Component (missing conditional) or     |
|                     | Hook (bad query key)                   |
| Stale data          | TanStack Query (cache invalidation)    |
| Auth failure        | Middleware (token parsing) or          |
|                     | Service (permission logic)             |
| Slow response       | Repository (missing index, N+1 query)  |
| Data corruption     | Migration (schema mismatch) or         |
|                     | Repository (bad UPDATE query)          |
+---------------------+----------------------------------------+
```

### 2. Identify the Affected Layer

Trace the request/data flow from the symptom backward to the root cause:

**If the bug is in the API response:**
1. Check the handler: Is the response being constructed correctly?
2. Check the service: Is the business logic producing the right result?
3. Check the repository: Is the SQL query correct?
4. Check the migration: Is the schema what the query expects?

**If the bug is in the UI:**
1. Check the component: Is it rendering the data correctly?
2. Check the hook/query: Is the API response being parsed correctly?
3. Check the API client: Is the request being constructed correctly?
4. Check the endpoint: Is the backend returning what the frontend expects?

**If the bug is in data integrity:**
1. Check the migration: Are constraints correct (unique, FK, not null)?
2. Check the repository: Are writes using parameterized queries?
3. Check the service: Are business rules enforced before writing?
4. Check concurrent access: Are transactions used where needed?

For each layer checked, note the specific file and line number examined.

### 3. Propose Fix Approach

Based on the root cause identified, propose a targeted fix:

**Fix Scope Rules:**
- Fix ONLY the root cause. Do not refactor surrounding code.
- If the fix requires changes in multiple layers, list each change separately.
- If the fix requires a migration change, specify whether it is a new migration (additive) or requires data migration.
- If the fix requires a frontend change, specify the exact component and prop/state change.

**Output the fix proposal:**

```markdown
### Bug: {Title}

**Root Cause:** {1-2 sentences identifying the exact cause}
**Affected Layer:** Handler | Service | Repository | Migration | Component | Hook | DTO
**Affected Files:**
- `{file_path}:{line}` -- {what is wrong}
- `{file_path}:{line}` -- {what is wrong}

**Proposed Fix:**
1. In `{file}:{line}` -- {change description}
2. In `{file}:{line}` -- {change description}

**Risks:**
- {Any side effects or regressions to watch for}

**Verification:**
- {How to verify the fix works}
- {What regression tests to run}
```

### 4. Review the Fix

After the fix is implemented (by a dev agent or human), review it:

**Correctness Check:**
- Does the fix address the root cause identified in step 2?
- Does the fix handle edge cases (null values, empty lists, concurrent access)?
- Does the fix introduce any new error paths that are not handled?

**Design Conformance Check:**
- Does the fix maintain layer separation (handler/service/repository)?
- Does the fix match the design document's API contract?
- Does the fix match the design document's DB schema?
- Are any new fields/endpoints added to the design doc?

**Scope Check:**
- Does the fix ONLY change what is necessary?
- Are there any unrelated changes bundled in?
- Are any refactoring changes mixed with the bug fix?

**Regression Check:**
- Could this fix break any other endpoint or component?
- Does this fix change any shared utility or model?
- Are existing tests still valid after this change?

**Output the fix review:**

```markdown
### Fix Review: {Title}

**Verdict:** APPROVED | NEEDS CHANGES | REJECTED

**Root Cause Addressed:** YES | PARTIAL | NO
**Design Conformance:** OK | DEVIATION (specify)
**Scope:** CLEAN | HAS UNRELATED CHANGES

**Issues Found:**
| # | Severity | File:Line | Description | Suggestion |
|---|----------|-----------|-------------|------------|

**Regression Risks:**
- {Potential regression and mitigation}

**Recommendation:**
{What to do next -- merge, fix issues, or rethink approach}
```

### 5. Report to El-Capitan

Delegate back via `/invoke-el-capitan` with:
- Bug root cause summary
- Fix verdict (APPROVED / NEEDS CHANGES / REJECTED)
- Any blocking issues
- Whether the fix is ready for merge

## Checklist

- [ ] Bug report fully analyzed (symptom, expected, actual, reproduction)
- [ ] Affected architectural layer identified with file:line references
- [ ] Root cause identified (not just symptom addressed)
- [ ] Fix approach is minimal and targeted (no scope creep)
- [ ] Fix maintains layer separation (handler/service/repository)
- [ ] Fix conforms to design document
- [ ] Edge cases considered (null, empty, concurrent)
- [ ] Regression risks identified
- [ ] Verification steps defined
- [ ] Output matches FORMAT.md structure
