# Communication Style

This file defines how agents using the qa-go skill communicate.

## Tone

Precise, test-focused, and evidence-backed. Every statement references concrete test output, coverage numbers, or code locations. Confident and direct — no hedging, no filler. Report failures matter-of-factly with diagnosis and recommended fix.

## Reporting Style

- **Lead with the outcome**: pass/fail count, coverage summary, and critical issues first. Details second.
- **Use tables** for file lists, mock implementations, and coverage breakdowns — scannable at a glance.
- **Bullet points** for issues, ordered by severity (critical → warn → info).
- **Include file:line references** for every issue — readers should be able to jump directly to the problem.
- **Keep it concise**: a test report should fit in one screen. If it doesn't, you tested too many things in one run or you're being too verbose.

## Test Description Language

Write test names and subtest names in terms of **what the function does and what outcome is expected**, not in terms of mock setup or internal mechanics.

### Good (behavior-centric)
```
"success - creates user with valid input"
"error - duplicate email returns conflict"
"error - missing required field returns validation error"
"success - returns paginated list with correct total count"
"error - expired token returns unauthorized"
"error - database timeout returns internal error"
```

### Bad (implementation-centric)
```
"test case 1"
"when mock returns nil"
"calls repository.Create"
"sets err to non-nil"
"mock setup with GetByEmail returning ErrNotFound"
```

### Mapping Rule
If you catch yourself writing about mock setup, internal function calls, or variable names in a test title, rewrite it from the function's contract perspective. The test body handles the mock setup — the **name** describes the behavioral scenario.

## Issue Flagging

- **[CRITICAL]** — Test failure, missing test for security-sensitive path (auth, permissions, input validation), data race detected, or coverage critically below target (>15% gap). Must be fixed before merge.
- **[WARN]** — Coverage below target but within 15%, untested edge case for non-critical path, fragile test pattern (time-dependent, order-dependent), or missing error path test. Should be fixed.
- **[INFO]** — Suggestion for improvement, additional test case idea, refactoring opportunity, or performance test recommendation. Optional.

## Terminology

Use these terms consistently across all test reports:

| Use | Not |
|-----|-----|
| test case | scenario, spec, it block |
| subtest | sub-test, nested test |
| table-driven test | parameterized test, data-driven test |
| assertion | check, verification, expectation |
| mock | stub, fake, double (unless specifically describing a different pattern) |
| coverage | code coverage percentage, cover |
| test file | spec file, test suite |
| test helper | utility function, test fixture |
| handler test | HTTP test, endpoint test |
| service test | business logic test, unit test (too vague) |
| repository test | data layer test, database test |
| integration test | end-to-end test (reserve E2E for full-stack) |
| race-clean | no races, thread-safe (in test context) |
| flag untested code | UNTESTED: [function/path description] |

## Status Update Format

When reporting progress mid-task:

```
[TESTING] Writing service tests for UserService (3 of 5 services)
[TESTING] Running go test -v -race -cover — 38/42 tests pass, investigating 4 failures
[TESTING] Fixing mock setup for ProjectService.Delete, re-running tests
[DONE] All 42 tests pass. Coverage: 81%. Race-clean. Report ready.
```

## Error Reporting

When a test fails, always include:
1. **Test name** (function + subtest)
2. **What was expected** (assertion expectation)
3. **What actually happened** (actual value)
4. **File and line** (for developer context)
5. **Likely cause** (brief diagnosis)

```
FAILED: TestUserService_Create/error_-_duplicate_email_returns_conflict
  Expected: error wrapping ErrAlreadyExists
  Actual:   nil (no error returned)
  File:     internal/service/user_service_test.go:87
  Cause:    Service.Create does not check for existing email before insert
```

## Response Structure

Always structure your final report in this order:
1. Summary (1-3 sentences)
2. Files table
3. Mocks table
4. Test results (total/passed/failed/skipped + race status)
5. Coverage table
6. Quality checklist
7. Issues & recommendations

Never reorder these sections. Downstream parsers depend on this structure.
