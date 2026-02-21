# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze

Perform all of the following — these are real analysis steps, not simulated:

1. **Read Source Files** — Scan all Go source files in scope. Identify every exported function, method, and interface across handler, service, and repository layers.

2. **Map Interfaces** — Identify every interface that needs a mock implementation. List the interface name, package, and all methods with signatures.

3. **Catalog Existing Tests** — Check for existing `*_test.go` files. Note what is already covered, what gaps exist, and which tests may need updating.

4. **Identify Testable Units** — For each layer, list every function that needs tests:
   - **Handlers**: Every HTTP handler method → needs httptest + mock service
   - **Services**: Every business logic method → needs table-driven tests + mock repository
   - **Repositories**: Every data access method → needs sqlmock or testcontainers
   - **Middleware**: Every middleware function → needs httptest + mock dependencies

5. **Map Error Paths** — For each function, identify all error returns and classify them:
   - Validation errors (bad input)
   - Not-found errors (missing data)
   - Conflict errors (duplicate)
   - Permission errors (unauthorized)
   - Internal errors (infrastructure failure)

6. **Check Test Infrastructure** — Verify that test utilities exist:
   - `internal/testutil/helpers.go` — request builders, response decoders
   - `internal/testutil/factories.go` — test data factories
   - Required dependencies in `go.mod` (testify, sqlmock, etc.)

7. **Assess Complexity** — Rate each testable unit:
   - **Simple**: Pure function, 1-2 branches → 2-3 test cases
   - **Medium**: Multiple branches, 1 dependency → 4-6 test cases
   - **Complex**: Multiple dependencies, error wrapping, context handling → 7+ test cases

## What to Output

The dry-run report MUST contain all of the following sections:

### 1. Test File Plan

| File to Create | Layer | Functions to Test | Test Count | Complexity |
|---------------|-------|-------------------|------------|------------|
| `internal/handler/user_handler_test.go` | handler | GetByID, Create, Update, Delete, List | 15 | medium |
| `internal/service/user_service_test.go` | service | GetByID, Create, Update, Delete, List | 20 | complex |
| `internal/repository/user_repo_test.go` | repository | GetByID, Create, Update, Delete, List | 10 | medium |

### 2. Test Cases Per Function

For each test file, list every test case that would be written:

```
TestUserService_Create:
  - success - creates user with valid input
  - error - duplicate email returns conflict
  - error - empty email returns validation error
  - error - repository Create failure returns internal error
  - error - context cancelled returns context error

TestUserService_GetByID:
  - success - returns user by ID
  - error - user not found returns ErrNotFound
  - error - invalid UUID returns validation error
  - error - repository failure returns internal error

TestUserHandler_GetByID:
  - success - returns 200 with user JSON
  - error - invalid UUID returns 400
  - error - user not found returns 404
  - error - internal error returns 500
```

### 3. Mock Implementations Needed

| Mock Type | Interface | Package | Methods | File |
|-----------|-----------|---------|---------|------|
| `MockUserRepository` | `UserRepository` | `repository` | GetByID, GetByEmail, Create, Update, Delete, List | `internal/service/mock_user_repo_test.go` |
| `MockUserService` | `UserService` | `service` | GetByID, Create, Update, Delete, List | `internal/handler/mock_user_svc_test.go` |

### 4. Test Infrastructure Status

```
internal/testutil/helpers.go:     EXISTS / MISSING / NEEDS UPDATE
internal/testutil/factories.go:   EXISTS / MISSING / NEEDS UPDATE
testify in go.mod:                YES / NO
sqlmock in go.mod:                YES / NO
testcontainers in go.mod:         YES / NO
```

If anything is missing, describe exactly what needs to be created/installed.

### 5. Coverage Expectations

| Package | Functions in Scope | Expected Coverage | Current Coverage | Gap |
|---------|--------------------|-------------------|------------------|-----|
| internal/service | 10 | 82% | 0% | 82% |
| internal/handler | 8 | 74% | 0% | 74% |
| internal/repository | 6 | 65% | 0% | 65% |
| internal/middleware | 2 | 85% | 0% | 85% |

### 6. Risks & Dependencies

- Potential blockers (e.g., interface not defined yet, missing model types)
- Complex functions that may need special test setup (e.g., file upload handlers, WebSocket handlers)
- Dependencies on other agents' output (e.g., "needs handler implementations from go-dev agent")
- Functions that are hard to test in isolation (tight coupling, global state)

### 7. Estimated Scope

```
Test files to create:     8
Mock files to create:     4
Helper files to create:   2
Total test cases:         56
Estimated execution time: ~2s (unit) + ~30s (integration)
Dependencies to add:      2 (testify, sqlmock)
```

## What NOT to Do

- DO NOT create, modify, or delete any test files
- DO NOT create mock implementation files
- DO NOT modify `go.mod` or `go.sum`
- DO NOT install packages or run build commands
- DO NOT run `go test`
- DO NOT create or modify helper/factory files
- DO still read all source files, analyze code paths, and make real testing decisions
- DO still identify exact test cases with specific names, not vague summaries
- DO still map exact function signatures and error types from the source code
