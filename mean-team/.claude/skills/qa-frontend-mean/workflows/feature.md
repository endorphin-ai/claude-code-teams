# Workflow: Write Frontend Tests for New Feature

Use this playbook when writing tests for a newly implemented React frontend.

## Steps

1. **Read Context** -- Load PRD, React architecture design, and frontend implementation summary from previous phases.

2. **Setup Test Infrastructure** -- Create MSW mock server, handlers for all API endpoints, test setup file, renderWithProviders utility.

3. **Write Common Component Tests** -- For each reusable component:
   - Renders with default props
   - Renders with each variant
   - Handles user interactions (click, type, hover)
   - Shows loading/disabled states
   - Applies correct styles/classes

4. **Write Form Tests** -- For each form component:
   - Submits with valid data
   - Shows validation errors for invalid data
   - Shows per-field errors
   - Disables submit button during submission
   - Clears errors on input change

5. **Write Page Tests** -- For each page:
   - Shows loading state initially
   - Displays data after successful API call
   - Shows error message on API failure
   - Handles empty data state
   - Renders within correct layout

6. **Write Hook Tests** -- For each custom hook:
   - Returns correct initial state
   - Updates state correctly after actions
   - Handles errors
   - Works with context providers

7. **Write Auth Flow Tests** -- Test the complete auth flow:
   - Login: sets user + token
   - Logout: clears user + token
   - Protected route: redirects to login when unauthenticated
   - Protected route: renders when authenticated

8. **Run Tests** -- Execute `npm test` and collect results.

9. **Check Coverage** -- Run with `--coverage` and verify targets met.

10. **Format Output** -- Structure per FORMAT.md.

## Checklist
- [ ] MSW mock server covers all API endpoints
- [ ] All common components tested
- [ ] All forms tested (valid + invalid + submitting states)
- [ ] All pages tested (loading + success + error states)
- [ ] All custom hooks tested
- [ ] Auth flow fully tested
- [ ] Tests use accessible queries (getByRole, getByLabelText)
- [ ] Tests pass (or failures documented)
- [ ] Coverage targets met
- [ ] Output matches FORMAT.md
