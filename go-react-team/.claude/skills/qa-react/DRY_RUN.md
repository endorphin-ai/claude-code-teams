# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze

Perform all of the following — these are real analysis steps, not simulated:

1. **Read the PRD** — Extract acceptance criteria, user flows, and API contracts that need test coverage.
2. **Scan the component tree** — Identify every component, hook, page, and utility in scope. Map their dependencies.
3. **Catalog existing tests** — Check for existing `.test.tsx` / `.test.ts` files. Note what is already covered and what gaps exist.
4. **Map API endpoints** — From the PRD and source code, list every API endpoint that components call. These become MSW handler candidates.
5. **Identify providers and wrappers** — Determine what context providers (Router, QueryClient, Auth, Theme) are needed for rendering components in tests.
6. **Assess complexity** — Rate each component/hook by testing complexity: simple (render + assert), medium (user interaction), complex (async + multiple API calls + state transitions).
7. **Check test infrastructure** — Verify that `src/test/setup.ts`, `src/test/test-utils.tsx`, and `vitest.config.ts` exist and are configured. Note any missing setup.

## What to Output

The dry-run report MUST contain all of the following sections:

### 1. Test File Plan

| File to Create | Component Under Test | Test Count | Complexity | Coverage Target |
|---------------|---------------------|------------|------------|-----------------|
| `src/components/LoginForm.test.tsx` | LoginForm | 5 | medium | 80%+ |
| `src/hooks/useAuth.test.ts` | useAuth | 4 | complex | 80%+ |
| `src/pages/DashboardPage.test.tsx` | DashboardPage | 3 | complex | 70%+ |

### 2. Test Cases Per Component

For each test file, list every test case that would be written:

```
LoginForm.test.tsx:
  - renders email and password fields
  - user can submit form with valid credentials
  - user sees validation error when email is empty
  - user sees validation error when password is too short
  - submit button is disabled while request is in progress

useAuth.test.ts:
  - returns null user when not authenticated
  - returns user data after successful login
  - clears user data on logout
  - handles 401 response by redirecting to login
```

### 3. MSW Handlers Needed

| Endpoint | Method | Scenarios | Handler File |
|----------|--------|-----------|-------------|
| `/api/v1/auth/login` | POST | success, invalid credentials, server error | `src/test/handlers/auth.ts` |
| `/api/v1/user/me` | GET | authenticated, unauthenticated | `src/test/handlers/user.ts` |
| `/api/v1/projects` | GET | list with data, empty list, server error | `src/test/handlers/projects.ts` |

### 4. Test Infrastructure Status

```
vitest.config.ts:         EXISTS / MISSING / NEEDS UPDATE
src/test/setup.ts:        EXISTS / MISSING / NEEDS UPDATE
src/test/test-utils.tsx:  EXISTS / MISSING / NEEDS UPDATE
MSW installed:            YES / NO
jest-axe installed:       YES / NO
user-event installed:     YES / NO
```

If anything is missing, describe exactly what needs to be created/installed.

### 5. Provider Wrapper Requirements

List the providers needed in the custom render wrapper:

```
Required providers:
  - BrowserRouter (react-router-dom) — for components using useNavigate, Link
  - QueryClientProvider (@tanstack/react-query) — for hooks using useQuery/useMutation
  - AuthProvider (src/contexts/AuthContext) — for components reading auth state
```

### 6. Coverage Expectations

| Category | Files in Scope | Expected Coverage | Notes |
|----------|---------------|-------------------|-------|
| Business hooks | 2 | 85%+ | useAuth, useProjects |
| Form components | 2 | 80%+ | LoginForm, CreateProjectModal |
| Page components | 1 | 70%+ | DashboardPage |
| Utilities | 1 | 90%+ | formatDate |

### 7. Risks & Dependencies

- Potential blockers (e.g., component depends on unimplemented API, missing types)
- Complex scenarios that may be hard to test (e.g., WebSocket interactions, file uploads)
- Dependencies on other agents' output (e.g., "needs component files from frontend-react agent")

### 8. Estimated Scope

```
Test files to create:    7
Test cases total:        28
MSW handler files:       3
Setup files to create:   1 (test-utils.tsx)
Setup files to update:   1 (setup.ts — add new handlers)
Estimated run time:      ~3s
```

## What NOT to Do

- DO NOT create, modify, or delete any test files
- DO NOT create or modify MSW handler files
- DO NOT install packages or run `npm install`
- DO NOT run `vitest` or any test commands
- DO NOT modify `vitest.config.ts` or `setup.ts`
- DO still read all source files, skills, and PRD — the analysis must be real
- DO still identify exact test cases, not vague summaries
- DO still map exact API endpoints and response shapes from the source code
