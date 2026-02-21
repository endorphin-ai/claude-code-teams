# Workflow: Bug Fix

Use this playbook when fixing a reported bug in Go backend code.

## Prerequisites

Before starting, ensure you have:
- Bug report with reproduction steps, expected behavior, and actual behavior
- The failing endpoint or component identified (or enough info to find it)

## Steps

### 1. Understand the Bug

Read the bug report thoroughly. Extract:
- **Affected endpoint:** Which HTTP method + path is failing?
- **Expected behavior:** What should happen?
- **Actual behavior:** What happens instead? (wrong status code, wrong response body, panic, timeout, etc.)
- **Reproduction conditions:** Specific input, auth state, data preconditions.

If the bug report is vague, note ambiguities as `[WARN]` in the report. Fix based on best interpretation.

### 2. Locate the Failing Code

Trace through the layers starting from the endpoint:

1. **Router** -- Find the route registration in `internal/router/router.go`. Confirm the handler is wired to the correct path and method.

2. **Middleware** -- Check if middleware is interfering (auth rejecting valid requests, CORS blocking, recovery swallowing panics silently).

3. **Handler** -- Read the handler method. Check for:
   - Incorrect request parsing (wrong field names, missing validation)
   - Wrong HTTP status codes in responses
   - Incorrect error mapping
   - Missing path parameter extraction

4. **Service** -- Read the service method. Check for:
   - Wrong business logic (incorrect conditions, missing edge cases)
   - Incorrect error wrapping (wrong sentinel error used)
   - Missing nil checks
   - Race conditions in multi-step operations

5. **Repository** -- Read the repository method. Check for:
   - SQL errors (wrong column names, missing WHERE clauses, incorrect JOINs)
   - Wrong scan order (columns scanned in different order than SELECT)
   - Missing error handling for `pgx.ErrNoRows`
   - Transaction misuse

6. **Model** -- Check struct definitions for:
   - Missing or incorrect JSON tags (frontend receives wrong field names)
   - Missing or incorrect DB tags
   - Type mismatches between Go types and PostgreSQL column types

### 3. Identify Root Cause

Before fixing, write down the root cause. A proper root cause is:
- **Specific:** "The `GetByID` repository method scans `description` before `name` but the SELECT lists `name` before `description`."
- **Not a symptom:** "The endpoint returns 500" is a symptom, not a root cause.
- **Explains the behavior:** The root cause must logically produce the observed bug.

### 4. Apply the Fix

Rules for the fix:
- **Minimal:** Change only what is necessary to fix the bug. No refactoring, no "while I am here" improvements.
- **Same layer:** Fix the bug where it originates. If the SQL is wrong, fix the SQL. Do not add a workaround in the handler.
- **Preserve behavior:** Do not change the API contract (request/response shapes, status codes) unless that is the bug.
- **Error handling:** If the bug is a missing error check, add proper error wrapping: `fmt.Errorf("context: %w", err)`.

Common fix patterns:

```go
// Fix: Wrong scan order
// Before (broken):
err := row.Scan(&p.ID, &p.Description, &p.Name)
// After (fixed -- matches SELECT column order):
err := row.Scan(&p.ID, &p.Name, &p.Description)

// Fix: Missing ErrNoRows handling
// Before (broken):
if err != nil {
    return nil, fmt.Errorf("repo.GetByID: %w", err)
}
// After (fixed):
if err != nil {
    if errors.Is(err, pgx.ErrNoRows) {
        return nil, model.ErrNotFound
    }
    return nil, fmt.Errorf("repo.GetByID: %w", err)
}

// Fix: Wrong status code
// Before (broken):
respondJSON(w, http.StatusOK, created)
// After (fixed):
respondJSON(w, http.StatusCreated, created)
```

### 5. Check for Related Issues

After fixing the primary bug, scan for the same pattern elsewhere:
- If the bug was a wrong scan order, check all other `Scan()` calls in the same repository.
- If the bug was a missing error check, check other methods in the same file.
- If the bug was a SQL issue, check similar queries.

Fix related instances only if they have the exact same bug. Note others as `[WARN]` if uncertain.

### 6. Build Verification

Run and capture output:

```bash
go build ./...
go vet ./...
```

Both must pass. If the fix introduces a new compilation error, the fix is wrong -- revisit.

### 7. Report Results

Produce output following FORMAT.md:

1. **Summary:** "Fixed {bug description} in `{endpoint}`. Root cause: {one-sentence root cause}."
2. **Files Created/Modified:** Only files actually changed.
3. **Code Summary:** Describe the fix (what changed, which layer).
4. **Build Verification:** Output from go build and go vet.
5. **Dependencies Added:** Usually "No new dependencies."
6. **Issues & Recommendations:** Related issues found, prevention suggestions.
7. **Quality Checklist.**

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] Root cause identified (not just symptoms treated)
- [ ] Fix is minimal and targeted to the correct layer
- [ ] No unrelated changes included
- [ ] Related occurrences of the same bug checked
- [ ] Error wrapping preserved or added where missing
- [ ] API contract unchanged (unless that was the bug)
- [ ] `go build ./...` passes
- [ ] `go vet ./...` passes
- [ ] Output matches FORMAT.md
