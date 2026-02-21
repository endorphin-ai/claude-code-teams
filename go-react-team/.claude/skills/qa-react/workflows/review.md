# Workflow: Test Code Review

Use this playbook when reviewing existing React test code for quality, correctness, and adherence to best practices. This applies to tests written by other agents, by humans, or during a pre-merge review gate.

## Prerequisites

- Test files to review are identified (specific files or a directory)
- Access to the source components/hooks being tested

## Steps

### 1. Catalog Tests in Scope

- List all test files to review.
- For each test file, identify the source file it tests.
- Count test cases per file.
- Note any source files that lack test coverage entirely.

**Output:** Table of test files, source files, and test counts. List of untested source files.

### 2. Check RTL Query Priority

For every query used in the tests, verify it follows the RTL priority order:

| Priority | Query | When to Use |
|----------|-------|-------------|
| 1 | `getByRole` | Always try first — buttons, headings, links, form controls |
| 2 | `getByLabelText` | Form inputs with labels |
| 3 | `getByPlaceholderText` | Inputs without labels (not ideal) |
| 4 | `getByText` | Non-interactive text content |
| 5 | `getByDisplayValue` | Current input/textarea values |
| 6 | `getByAltText` | Images |
| 7 | `getByTitle` | Title attributes |
| 8 | `getByTestId` | Last resort only |

**Flag as [WARN]:**
- Using `getByTestId` when `getByRole` or `getByLabelText` would work
- Using `getByText` for buttons (should be `getByRole('button', { name: ... })`)
- Using `container.querySelector` for anything

**Flag as [CRITICAL]:**
- Using `container.innerHTML` or string matching on HTML
- Directly accessing component internals or state

### 3. Check for Implementation Detail Testing

Scan for anti-patterns that test implementation rather than behavior:

**[CRITICAL] Anti-patterns to flag:**
- Asserting on component state variables (`wrapper.state()`, internal state references)
- Asserting on hook return value internals that aren't user-visible
- Testing that specific internal functions were called (unless they're passed-in callbacks)
- Asserting on CSS classes or style properties for behavior (use ARIA roles instead)
- Using `wrapper.instance()` or accessing component internals via ref

**[WARN] Borderline patterns:**
- Mocking child components with `vi.mock` (prefer rendering the real component tree)
- Asserting exact number of re-renders
- Testing prop drilling (assert on user-visible result instead)

### 4. Verify Async Handling

Check that async operations are tested correctly:

**[CRITICAL] Issues:**
- Using `setTimeout` or `sleep` to wait for async updates
- Missing `await` on `user.click()`, `user.type()`, or other userEvent calls
- Using `act()` wrapper when `waitFor` or `findBy` would be cleaner
- Not awaiting `waitFor` calls

**[WARN] Issues:**
- Using `waitFor` when `findBy` query would suffice (simpler)
- Hardcoded wait times instead of condition-based waiting
- Missing `waitForElementToBeRemoved` for loading states (testing with arbitrary `findBy` instead)

### 5. Review MSW Usage

Check that API mocking follows MSW best practices:

**[CRITICAL] Issues:**
- Using `vi.mock('axios')` or `vi.mock('../api')` instead of MSW for HTTP requests
- Mocking `fetch` directly with `vi.fn()` instead of MSW
- MSW handlers that don't match the real API contract (wrong URL, wrong response shape)

**[WARN] Issues:**
- All MSW handlers inline in test files instead of centralized in `src/test/handlers/`
- Missing error scenario handlers (only testing happy path)
- No `server.resetHandlers()` in `afterEach` (handlers leaking between tests)
- `onUnhandledRequest` not set to `'warn'` or `'error'`

### 6. Check Test Independence

Verify each test is isolated and doesn't depend on other tests:

**[CRITICAL] Issues:**
- Shared mutable variables modified across tests without reset
- Tests that depend on execution order (Test B only passes after Test A runs)
- Missing cleanup of global state (localStorage, cookies, DOM side effects)

**[WARN] Issues:**
- Large `beforeEach` blocks that render the component (prefer rendering per-test for clarity)
- Shared test data objects that could be accidentally mutated

### 7. Review Test Naming

Check that test names describe user behavior:

**[WARN] Issues:**
- Test names referencing implementation details ("calls setState", "dispatches action")
- Vague test names ("works correctly", "handles edge case", "renders properly")
- Test names not starting with a user-action verb or state description

**Good names:**
- "user sees error message when email is invalid"
- "submit button is disabled during form submission"
- "empty state is shown when no projects exist"

### 8. Check Accessibility Testing

**[WARN] Issues:**
- No `jest-axe` scans on form components
- No `jest-axe` scans on page-level components
- No focus management tests for modals and dialogs
- Missing keyboard navigation tests for custom interactive widgets

### 9. Verify Coverage Adequacy

- Run `npx vitest run --coverage` if possible, or analyze test cases against source code.
- Check against targets: 80%+ for hooks, 80%+ for form components, 70%+ for pages.
- Identify specific uncovered branches or code paths.

**[WARN] Issues:**
- Coverage below target without documented reason
- Only happy-path tested (no error states, no empty states, no edge cases)
- Missing tests for conditional rendering branches

### 10. Produce Review Report

Format the review as a structured report:

```
## Test Review Summary

Files reviewed: 8
Total test cases: 34
Issues found: 3 critical, 5 warnings, 2 info

## Review Detail

### src/components/LoginForm.test.tsx (5 tests)
- [CRITICAL] Line 23: Uses `container.querySelector('.error-msg')` — replace with `getByRole('alert')` or `getByText(/error message/i)`
- [WARN] Line 45: Test name "calls onSubmit with correct data" — rewrite as "user can submit the form with valid credentials"
- [INFO] Consider adding test for Tab key navigation between fields

### src/hooks/useAuth.test.ts (4 tests)
- [WARN] Line 12: Using `vi.mock('../api/auth')` — replace with MSW handler for `/api/v1/auth/login`
- [WARN] Missing error path test — add test for 401 response

### src/pages/DashboardPage.test.tsx (3 tests)
- [CRITICAL] Line 8: Using `setTimeout(() => ..., 500)` for async wait — replace with `await waitForElementToBeRemoved()`
- [CRITICAL] Tests share a mutable `mockData` array that gets `.push()` in test 2, breaking test 3 in isolation
- [INFO] No accessibility scan — add `jest-axe` check

## Quality Checklist

- [ ] RTL query priority followed
- [x] user-event used for interactions
- [ ] Async handling correct (2 violations)
- [ ] MSW for API mocking (1 violation — vi.mock used)
- [ ] No implementation details tested
- [ ] Tests are independent (1 violation — shared mutable state)
- [ ] Accessibility scanned
- [x] Test names are user-centric

## Recommendations

1. Replace `container.querySelector` with RTL semantic queries (2 instances)
2. Migrate `vi.mock('../api/auth')` to MSW handlers
3. Fix shared mutable state in DashboardPage tests
4. Add jest-axe scans to DashboardPage and LoginForm
5. Add error-path tests for useAuth hook
```

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] All test files in scope reviewed
- [ ] RTL query priority checked
- [ ] No implementation detail testing
- [ ] Async handling verified
- [ ] MSW usage reviewed
- [ ] Test independence confirmed
- [ ] Test naming follows user-centric convention
- [ ] Accessibility testing present
- [ ] Coverage adequacy assessed
- [ ] Issues categorized by severity (CRITICAL / WARN / INFO)
- [ ] Actionable fix recommendations provided for every issue
- [ ] Output matches FORMAT.md structure
