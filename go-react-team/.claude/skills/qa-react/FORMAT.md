# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Summary

One to three sentences describing what was tested, the overall result, and any critical findings.

```
Wrote 14 tests across 4 files for the LoginForm, UserProfile, and DashboardPage components.
All tests pass. Coverage at 84% for components, 91% for hooks. One accessibility violation found in UserProfile (missing aria-label on icon button).
```

### 2. Test Files Created/Modified

| File | Tests | Coverage Target | Status |
|------|-------|-----------------|--------|
| `src/components/LoginForm.test.tsx` | 5 | 80%+ | created |
| `src/hooks/useAuth.test.ts` | 4 | 80%+ | created |
| `src/pages/DashboardPage.test.tsx` | 3 | 70%+ | created |
| `src/test/handlers/auth.ts` | - | - | created |

### 3. Test Results Summary

```
Total:   14
Passed:  13
Failed:   1
Skipped:  0

Duration: 2.4s
```

If any tests failed, list them:

```
FAILED:
  - LoginForm > shows server error when API returns 500
    Error: Expected "Server error" to be in the document, received "Loading..."
    File: src/components/LoginForm.test.tsx:47
```

### 4. Coverage Report

```
Component/Hook Coverage:
  src/components/LoginForm.tsx    87.5%  (target: 80%)  PASS
  src/hooks/useAuth.ts            91.2%  (target: 80%)  PASS
  src/pages/DashboardPage.tsx     72.1%  (target: 70%)  PASS
  src/components/UserProfile.tsx  65.3%  (target: 70%)  WARN — below target

Overall: 79.0%
```

### 5. MSW Handlers Created

| Endpoint | Method | Mock Response | File |
|----------|--------|---------------|------|
| `/api/v1/auth/login` | POST | `{ token: "...", user: {...} }` | `src/test/handlers/auth.ts` |
| `/api/v1/auth/login` | POST (error) | `{ error: "Invalid credentials" }` 401 | `src/test/handlers/auth.ts` |
| `/api/v1/user/me` | GET | `{ id: 1, name: "Test User" }` | `src/test/handlers/user.ts` |
| `/api/v1/projects` | GET | `[{ id: 1, name: "Alpha" }, ...]` | `src/test/handlers/projects.ts` |

### 6. Accessibility Results

```
Components scanned: 3
Violations found:   1

VIOLATIONS:
  [WARN] UserProfile — button element "settings-icon" missing accessible name
         Rule: button-name (WCAG 2.1 Level A)
         Fix:  Add aria-label="Settings" to the icon button
```

If no violations: `All scanned components pass accessibility checks.`

### 7. Quality Checklist

```markdown
- [x] All tests use RTL query priority (getByRole preferred)
- [x] User interactions use @testing-library/user-event, not fireEvent
- [x] Async operations use waitFor / findBy, not manual delays
- [x] API calls mocked with MSW at network level
- [x] No implementation details tested (no internal state assertions)
- [x] Each test is independent (no shared mutable state)
- [x] Accessibility scan run on form and page components
- [x] Coverage targets met or shortfall documented
- [ ] Snapshot tests limited to stable presentational components only
```

### 8. Issues & Recommendations

List any issues, categorized by severity:

```
[CRITICAL] LoginForm.test.tsx — test "shows server error" fails due to missing error boundary in component
[WARN]     UserProfile.tsx — coverage at 65.3%, below 70% target. Missing tests for edit mode toggle.
[INFO]     DashboardPage — consider adding E2E test for the full login-to-dashboard flow
```

## Output Example

```
## Summary
Wrote 8 tests across 3 files for the ProjectList, CreateProjectModal, and useProjects hook.
All tests pass. Component coverage at 82%, hook coverage at 93%. No accessibility violations.

## Test Files Created

| File | Tests | Coverage Target | Status |
|------|-------|-----------------|--------|
| `src/components/ProjectList.test.tsx` | 3 | 70%+ | created |
| `src/components/CreateProjectModal.test.tsx` | 3 | 80%+ | created |
| `src/hooks/useProjects.test.ts` | 2 | 80%+ | created |
| `src/test/handlers/projects.ts` | - | - | created |

## Test Results

Total: 8 | Passed: 8 | Failed: 0 | Skipped: 0 | Duration: 1.8s

## Coverage

  src/components/ProjectList.tsx        78.4%  (target: 70%)  PASS
  src/components/CreateProjectModal.tsx  84.2%  (target: 80%)  PASS
  src/hooks/useProjects.ts              93.1%  (target: 80%)  PASS

Overall: 85.2%

## MSW Handlers

| Endpoint | Method | Mock Response | File |
|----------|--------|---------------|------|
| `/api/v1/projects` | GET | `[{id:1, name:"Alpha"}, {id:2, name:"Beta"}]` | `src/test/handlers/projects.ts` |
| `/api/v1/projects` | POST | `{id:3, name:"New Project"}` 201 | `src/test/handlers/projects.ts` |

## Accessibility

Components scanned: 2 | Violations found: 0
All scanned components pass accessibility checks.

## Quality Checklist

- [x] RTL query priority followed
- [x] user-event for interactions
- [x] Async handling with waitFor/findBy
- [x] MSW for API mocking
- [x] No implementation details tested
- [x] Independent tests
- [x] Accessibility scanned
- [x] Coverage targets met

## Issues & Recommendations

[INFO] ProjectList — consider snapshot test for empty state UI (stable, presentational)
```
