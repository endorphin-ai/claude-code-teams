# Workflow: Feature Test Writing

Use this playbook when writing tests for a new feature delivered from the PRD.

## Prerequisites

- PRD is available with acceptance criteria and API contracts
- React component/hook/page files have been created by the frontend-react agent
- Go backend API contracts are defined (endpoints, request/response shapes)

## Steps

### 1. Read PRD + Component Tree + Source Files

- Read the PRD to extract acceptance criteria, user flows, and API contracts.
- Scan `src/` for all new or modified `.tsx` and `.ts` files related to the feature.
- Build a mental map: which components render what, which hooks call which APIs, which pages compose which components.
- Identify every user-facing behavior that needs a test.

**Output:** List of components, hooks, and pages in scope. List of user behaviors to test.

### 2. Verify Test Infrastructure

- Confirm `vitest.config.ts` has `setupFiles` pointing to `src/test/setup.ts`.
- Confirm `src/test/setup.ts` exists with MSW server lifecycle hooks.
- Confirm `src/test/test-utils.tsx` exists with custom render wrapping all necessary providers.
- If any are missing, create them before writing any tests.
- Check that dependencies are installed: `@testing-library/react`, `@testing-library/user-event`, `msw`, `@testing-library/jest-dom`, `jest-axe`.

**Output:** Infrastructure status (ready / files created).

### 3. Set Up MSW Handlers for API Endpoints

- For every API endpoint the feature's components/hooks call, create an MSW handler.
- Place handlers in `src/test/handlers/{domain}.ts` (e.g., `auth.ts`, `projects.ts`, `users.ts`).
- Each handler file exports an array of `http.*` handlers.
- Include success responses matching the Go backend's API contract.
- Register new handler arrays in `src/test/setup.ts` server.

**Handler template:**
```typescript
import { http, HttpResponse } from 'msw';

export const projectHandlers = [
  http.get('/api/v1/projects', () => {
    return HttpResponse.json([
      { id: 1, name: 'Project Alpha', status: 'active' },
      { id: 2, name: 'Project Beta', status: 'archived' },
    ]);
  }),

  http.post('/api/v1/projects', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: 3, ...body }, { status: 201 });
  }),
];
```

**Output:** MSW handler files created, registered in setup.

### 4. Write Component Unit Tests

For each component in scope:

1. Create `ComponentName.test.tsx` in the same directory as the component.
2. Import from `@/test/test-utils` (custom render), `@testing-library/user-event`, and `vitest`.
3. Write tests following the Arrange-Act-Assert pattern:

**Test categories per component:**
- **Render tests** — Component renders expected content in default state.
- **Interaction tests** — User clicks, types, selects, and the UI responds correctly.
- **Validation tests** — Form validation shows correct error messages.
- **Loading state tests** — Component shows loading indicator while fetching.
- **Error state tests** — Component handles API errors gracefully.
- **Empty state tests** — Component handles zero-data scenarios.
- **Accessibility test** — Run `jest-axe` on the rendered component.

**Naming convention:** Test names describe user behavior, not implementation.

```typescript
describe('CreateProjectModal', () => {
  it('renders the form with name and description fields', () => { ... });
  it('user can fill in the form and submit a new project', async () => { ... });
  it('user sees validation error when project name is empty', async () => { ... });
  it('submit button is disabled while saving', async () => { ... });
  it('user sees error message when server rejects the request', async () => { ... });
  it('has no accessibility violations', async () => { ... });
});
```

**Output:** Component test files created.

### 5. Write Hook Tests

For each custom hook in scope:

1. Create `useHookName.test.ts` in the same directory as the hook.
2. Use `renderHook` from `@testing-library/react`.
3. Provide necessary wrappers (QueryClientProvider, etc.) via a `wrapper` option.

**Test categories per hook:**
- **Initial state** — Hook returns expected default values.
- **Success path** — Hook fetches/mutates data correctly (MSW provides the response).
- **Error path** — Hook handles API errors (MSW returns error status).
- **Edge cases** — Empty responses, null values, concurrent calls.

```typescript
describe('useProjects', () => {
  it('returns empty array initially', () => { ... });
  it('fetches and returns project list', async () => { ... });
  it('handles server error gracefully', async () => { ... });
  it('refetches when invalidated', async () => { ... });
});
```

**Output:** Hook test files created.

### 6. Write Page Integration Tests

For each page component in scope:

1. Create `PageName.test.tsx` in the same directory as the page.
2. Use custom render from `@/test/test-utils` (includes Router, QueryClient, Auth).
3. Test the full user flow through the page:

**Test categories per page:**
- **Happy path** — Page loads, data appears, user can interact.
- **Loading state** — Page shows loading indicator, then content.
- **Error state** — API fails, page shows error UI.
- **Navigation** — User can navigate to/from this page.
- **Accessibility** — Full page accessibility scan.

```typescript
describe('ProjectListPage', () => {
  it('loads and displays the list of projects', async () => { ... });
  it('user sees empty state when no projects exist', async () => { ... });
  it('user sees error message when API fails', async () => { ... });
  it('user can navigate to project detail by clicking a project', async () => { ... });
  it('has no accessibility violations', async () => { ... });
});
```

For page tests, override MSW handlers per-test for error and empty scenarios:
```typescript
server.use(
  http.get('/api/v1/projects', () => {
    return HttpResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }),
);
```

**Output:** Page test files created.

### 7. Run Tests and Collect Coverage

Execute: `npx vitest run --coverage`

- All tests must pass. If any fail, diagnose and fix immediately.
- Check coverage against targets:
  - Business hooks: 80%+
  - Form/interactive components: 80%+
  - Page components: 70%+
- If coverage is below target, write additional test cases for uncovered branches.

**Output:** Test run results, coverage percentages.

### 8. Report Results

Produce output in FORMAT.md structure:
- Summary (pass/fail, coverage headline)
- Test Files Created table
- Test Results Summary (total, passed, failed)
- Coverage Report (per-file)
- MSW Handlers Created table
- Accessibility Results
- Quality Checklist
- Issues & Recommendations

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] All acceptance criteria from PRD have corresponding test cases
- [ ] MSW handlers match Go backend API contracts
- [ ] RTL query priority followed (getByRole > getByLabelText > ... > getByTestId)
- [ ] All interactions use userEvent, not fireEvent
- [ ] Async operations tested with waitFor / findBy
- [ ] No implementation details tested
- [ ] Each test is independent and isolated
- [ ] Accessibility scanned on all form and page components
- [ ] Coverage targets met or shortfall documented with reasoning
- [ ] Output matches FORMAT.md structure
