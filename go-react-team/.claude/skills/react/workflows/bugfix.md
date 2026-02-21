# Workflow: Bug Fix

Use this playbook when fixing a reported bug in the React frontend.

## Steps

### 1. Understand the Bug

- Read the bug report: expected behavior vs actual behavior
- Identify which page/route the bug occurs on
- Identify the user action that triggers the bug (click, form submit, navigation, page load, etc.)
- Determine the severity: UI glitch, broken functionality, crash, data loss

### 2. Locate the Failing Component

Trace the issue through the component tree:

1. **Start at the page component** -- which page is affected? (`src/pages/`)
2. **Check the component** -- which specific component renders incorrectly or fails? (`src/components/`)
3. **Check props** -- is the component receiving the correct props from its parent? Is the Props interface correct?
4. **Check state** -- is local state (`useState`), form state (React Hook Form), or server state (TanStack Query) behaving correctly?
5. **Check the hook** -- if a custom hook is involved (`src/hooks/`), check its query key, query function, and mutation callbacks
6. **Check the API call** -- is the API client function (`src/api/`) sending the correct request? Is the response type matching what the backend actually returns?
7. **Check types** -- does the TypeScript type (`src/types/api.ts`) match the actual backend response? A type mismatch can cause silent failures.

### 3. Identify Root Cause

Categorize the root cause:

| Category | Examples |
|----------|---------|
| **Props error** | Wrong prop type, missing required prop, stale prop value |
| **State error** | Incorrect initial state, missing state update, stale closure in useEffect |
| **API contract mismatch** | Backend changed response shape, missing field, wrong field name |
| **TanStack Query issue** | Wrong query key (stale cache), missing invalidation after mutation, incorrect enabled condition |
| **Form validation issue** | Zod schema too strict/lenient, missing field registration, incorrect resolver |
| **Routing issue** | Wrong path, missing route parameter, broken lazy import |
| **Rendering issue** | Missing loading state, unhandled null/undefined, conditional rendering logic error |
| **Styling issue** | Wrong Tailwind classes, responsive breakpoint issue, z-index conflict |
| **Type error** | TypeScript type does not match runtime data, missing type narrowing |

### 4. Fix

Apply the minimal fix that addresses the root cause:

- Fix only the root cause -- do not refactor unrelated code
- If the fix requires a type change in `src/types/api.ts`, verify the new type matches the actual backend response
- If the fix requires an API client change, verify the endpoint and request shape with the PRD
- If the fix touches a shared component, verify it does not break other consumers (search for imports of the component)
- Update the zod schema if the form validation was wrong
- Invalidate the correct TanStack Query cache keys if stale data was the issue

### 5. Verify

Run the build to verify no TypeScript errors were introduced:

```bash
npm run build
```

Manually verify the fix:
- The original bug behavior no longer occurs
- The expected behavior now works correctly
- Related functionality still works (check sibling components, other pages using the same hook/API function)
- Loading, error, and empty states still render correctly
- Form validation still works if forms were touched

### 6. Report

Output results in FORMAT.md structure:

```markdown
## Summary
Fixed [bug description]. Root cause: [category] -- [explanation].

## Files Created/Modified
| File | Purpose | Status |
|------|---------|--------|
| src/components/users/UserCard.tsx | Fixed prop type for onSelect callback | modified |

## Root Cause
[Category]: [Detailed explanation of what was wrong and why]

## Fix Applied
[Description of the change and why it resolves the issue]

## Build Verification
**Build status:** PASS
**TypeScript errors:** 0

## Regression Check
- [x] Original bug no longer reproduces
- [x] Related components still function correctly
- [x] No new TypeScript errors introduced

## Issues and Recommendations
[WARN/INFO] Any related issues discovered during investigation
```

Then delegate back to el-capitan.

## Checklist

- [ ] Root cause identified (not just symptoms treated)
- [ ] Fix is minimal and targeted -- no unrelated changes
- [ ] TypeScript types still match backend contracts
- [ ] No new `any` types introduced
- [ ] Loading/error/empty states still work
- [ ] `npm run build` passes with zero TypeScript errors
- [ ] Output matches FORMAT.md structure
- [ ] No files modified outside the bug scope
