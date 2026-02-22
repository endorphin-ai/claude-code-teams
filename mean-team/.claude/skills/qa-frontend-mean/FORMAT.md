# Output Format

This file defines the structured output that the Frontend QA agent MUST produce.

## Required Sections

### 1. Summary
1-3 sentences: what was tested, test count, pass/fail ratio.

### 2. Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| client/src/__tests__/setup.js | Test setup with MSW | created |
| client/src/__tests__/mocks/handlers.js | API mock handlers | created |
| client/src/components/common/Button.test.jsx | Button component tests | created |
```

### 3. Test Results

```markdown
| Test Suite | Tests | Passed | Failed | Coverage |
|-----------|-------|--------|--------|----------|
| Button.test.jsx | 4 | 4 | 0 | 100% |
| LoginForm.test.jsx | 5 | 5 | 0 | 95% |
| DashboardPage.test.jsx | 3 | 2 | 1 | 80% |
```

### 4. Test Coverage Summary

```markdown
| Category | Files | Lines | Functions | Branches |
|----------|-------|-------|-----------|----------|
| Components | 90% | 85% | 95% | 80% |
| Pages | 80% | 75% | 85% | 70% |
| Hooks | 95% | 90% | 100% | 85% |
| Context | 100% | 95% | 100% | 90% |
```

### 5. Failed Tests (if any)

```markdown
| Test | Suite | Error | Likely Cause |
|------|-------|-------|-------------|
| shows error on API failure | DashboardPage.test.jsx | Element not found | Missing error state in component |
```

### 6. Dependencies Added

```markdown
| Package | Purpose |
|---------|---------|
| @testing-library/react | Component testing |
| @testing-library/jest-dom | Custom DOM matchers |
| @testing-library/user-event | User interaction simulation |
| msw | API mocking |
```

### 7. Quality Checklist
- [ ] All pages have tests (loading, success, error states)
- [ ] All forms tested (valid submit, validation errors, disabled during submit)
- [ ] Auth flow tested (login, logout, protected routes, context)
- [ ] Common components tested (render, interactions, variants)
- [ ] Custom hooks tested
- [ ] MSW handlers cover all API endpoints
- [ ] No tests depend on other tests (isolated)
- [ ] Coverage above 80%

### 8. Issues & Recommendations
Numbered list of issues found during testing or improvements suggested.
