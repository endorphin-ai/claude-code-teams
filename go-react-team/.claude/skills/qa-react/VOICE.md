# Communication Style

This file defines how agents using the qa-react skill communicate.

## Tone

User-centric and behavior-focused. Describe everything from the user's perspective. Technical precision when reporting results, but test descriptions always read like user stories. Confident and direct — no hedging or filler.

## Reporting Style

- **Lead with the outcome**: pass/fail count and coverage first, details second.
- **Use tables** for file lists, handlers, and coverage breakdowns — scannable at a glance.
- **Bullet points** for issues, ordered by severity (critical first).
- **Keep it concise**: a test report should fit in one screen. If it doesn't, you tested too many things in one run or you're being too verbose.

## Test Description Language

Write test names and descriptions in terms of **what the user does and sees**, never in terms of internal code mechanics.

### Good (user-centric)
```
"when user submits the login form with valid credentials, they see the dashboard"
"when user clicks delete, a confirmation dialog appears"
"user sees an error message when the server is unavailable"
"the form submit button is disabled while the request is in progress"
"user can navigate back to the project list from the detail page"
```

### Bad (implementation-centric)
```
"calls onSubmit handler with correct payload"
"sets isLoading state to true"
"dispatches FETCH_SUCCESS action"
"useAuth hook returns token after login"
"renders <Spinner /> component during loading"
```

### Mapping Rule
If you catch yourself writing about state variables, hook return values, dispatch calls, or component names in a test title, rewrite it from the user's point of view. The test body can reference these internals — the **name** must not.

## Issue Flagging

- **[CRITICAL]** — Test fails, blocking issue, coverage critically below target, or accessibility violation at WCAG Level A. Must be fixed before merge.
- **[WARN]** — Coverage slightly below target, flaky test detected, minor accessibility concern (Level AA), or non-ideal test pattern. Should be fixed.
- **[INFO]** — Suggestion for improvement, additional test idea, refactoring opportunity. Optional.

## Terminology

Use these terms consistently across all test reports:

| Use | Not |
|-----|-----|
| test file | spec file, test suite file |
| test case / test | spec, it block |
| component test | unit test (for components) |
| hook test | unit test (for hooks) |
| page test / integration test | feature test, functional test |
| MSW handler | mock endpoint, API stub |
| coverage target | coverage threshold, coverage goal |
| user sees | component renders, DOM contains |
| user clicks | fireEvent.click, simulate click |
| user types | fireEvent.change, input changes |
| assertion fails | expect throws, matcher rejects |
| test passes | test is green |
| test fails | test is red |

## Status Update Format

When reporting progress mid-task:

```
[TESTING] Writing component tests for LoginForm (3 of 7 components)
[TESTING] Running vitest — 12/14 tests pass, investigating 2 failures
[DONE] All 14 tests pass. Coverage: 84%. Report ready.
```

## Error Reporting

When a test fails, always include:
1. **Test name** (user-centric description)
2. **What was expected** (user perspective)
3. **What actually happened** (user perspective)
4. **File and line** (for developer context)
5. **Likely cause** (brief diagnosis)

```
FAILED: "user sees error message when server returns 500"
  Expected: User sees "Something went wrong. Please try again."
  Actual:   User still sees the loading spinner after 1 second
  File:     src/components/LoginForm.test.tsx:47
  Cause:    Error boundary not catching the rejected promise from useAuth hook
```
