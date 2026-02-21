# Workflow: Test Writing for New Feature

Use this playbook when writing tests for newly implemented Go source code from a feature PRD.

## Prerequisites

- PRD is available with acceptance criteria and API contracts
- Go backend source files have been created by the go-dev agent
- Design document defines API endpoints, DB schema, and Go package structure
- `go build ./...` passes on the existing codebase

## Steps

### 1. Read PRD + Design Doc + Source Files

- Read the PRD to extract acceptance criteria, entities, and API contracts.
- Read the design document for API endpoint specs (method/path/request/response/status codes).
- Scan `internal/` for all new or modified `.go` files related to the feature.
- Build a complete map: which handlers serve which endpoints, which services implement which business logic, which repositories access which tables.
- Identify every function that needs tests and classify by layer.

**Output:** List of testable functions per layer. List of interfaces that need mocks.

### 2. Create Test Utilities (if needed)

If `internal/testutil/` does not exist:

- Create `internal/testutil/helpers.go` with:
  - `NewRequest(t, method, path, body)` — creates httptest.Request with JSON body
  - `WithChiURLParam(r, key, value)` — adds Chi URL parameter to request context
  - `WithChiURLParams(r, params)` — adds multiple Chi URL parameters
  - `DecodeResponse(t, rec, v)` — JSON-decodes response body
  - `AssertStatus(t, rec, expected)` — checks response status code

- Create `internal/testutil/factories.go` with:
  - Factory functions for each model type: `NewUser(overrides...)`, `NewProject(overrides...)`
  - Override functions: `WithEmail(email)`, `WithName(name)`, etc.
  - All factories return sensible defaults for all fields

If already exists, check if new model factories are needed for the feature.

**Output:** Test utility files created or confirmed existing.

### 3. Create Mock Implementations

For every interface that the feature's functions depend on:

1. Identify the interface (e.g., `repository.UserRepository`)
2. List all methods with full signatures
3. Create a mock implementation using `testify/mock`
4. Place mock files alongside the test files that use them:
   - Service test mocks: `internal/service/mock_*_test.go`
   - Handler test mocks: `internal/handler/mock_*_test.go`

**Mock template:**
```go
type MockUserRepository struct {
    mock.Mock
}

func (m *MockUserRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.User, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*model.User), args.Error(1)
}
```

**Rules:**
- Every method in the interface gets a mock method
- Pointer returns check `args.Get(0) == nil` before type assertion
- Use `mock.Anything` for `context.Context` parameters
- Never share mock instances between tests

**Output:** Mock implementation files created.

### 4. Write Repository Tests

For each repository method:

1. Create `*_test.go` in `internal/repository/`
2. Use `sqlmock` to mock database interactions
3. Write table-driven tests covering:
   - **Success path**: query returns expected rows
   - **Not found**: query returns `sql.ErrNoRows` → mapped to `repository.ErrNotFound`
   - **Database error**: query returns error → wrapped and returned
   - **Multiple rows** (for List): verify correct scanning and counting
   - **Constraint violation** (for Create/Update): unique constraint → `ErrConflict`

**Pattern:**
```go
func TestUserRepository_GetByID(t *testing.T) {
    db, mock, err := sqlmock.New()
    require.NoError(t, err)
    defer db.Close()

    repo := repository.NewUserRepository(db)
    // ... table-driven tests with mock.ExpectQuery
    require.NoError(t, mock.ExpectationsWereMet())
}
```

**Output:** Repository test files created.

### 5. Write Service Tests

For each service method:

1. Create `*_test.go` in `internal/service/`
2. Use mock repositories created in Step 3
3. Write table-driven tests covering:
   - **Success path**: valid input → expected output
   - **Validation errors**: invalid/missing fields → `ErrValidation`
   - **Not found**: entity doesn't exist → `ErrNotFound`
   - **Conflict**: duplicate entity → `ErrConflict`
   - **Repository failure**: infrastructure error → wrapped error
   - **Context cancellation**: cancelled context → `context.Canceled`
   - **Edge cases**: empty strings, nil values, boundary values, max-length inputs

**Minimum test cases per method:**
- Simple methods (GetByID, Delete): 3-4 test cases
- Medium methods (Create, Update): 5-7 test cases
- Complex methods (List with filters, batch operations): 7-10 test cases

**Output:** Service test files created.

### 6. Write Handler Tests

For each HTTP handler:

1. Create `*_test.go` in `internal/handler/`
2. Use `httptest` + mock services created in Step 3
3. Write table-driven tests covering:
   - **Success path**: valid request → correct status code + response body
   - **Invalid input**: malformed JSON → 400 Bad Request
   - **Missing fields**: required fields absent → 400 Bad Request
   - **Not found**: entity doesn't exist → 404 Not Found
   - **Conflict**: duplicate → 409 Conflict
   - **Unauthorized**: missing/invalid auth → 401 Unauthorized
   - **Internal error**: service failure → 500 Internal Server Error
   - **URL param validation**: invalid path params → 400 Bad Request

**For each test, verify:**
- Response status code matches expected
- Response body contains expected JSON fields
- Response Content-Type is `application/json`
- Mock service received expected method calls

**Output:** Handler test files created.

### 7. Write Middleware Tests (if applicable)

If the feature includes new middleware:

1. Create `*_test.go` in `internal/middleware/`
2. Use a test handler (`http.HandlerFunc`) behind the middleware
3. Test the middleware's pass-through and blocking behavior
4. Cover: valid input passes through, invalid input is blocked with correct status code

**Output:** Middleware test files created.

### 8. Run Test Suite

Execute: `go test -v -race -cover ./...`

- All tests must pass. If any fail:
  1. Diagnose the failure (test bug vs. code bug)
  2. If test bug: fix the test
  3. If code bug: document as [CRITICAL] issue in the report
- Check race detector output: must be CLEAN
- Check coverage against targets:
  - Services: 80%+
  - Handlers: 70%+
  - Repositories: 60%+
  - Middleware: 80%+
- If coverage is below target, write additional test cases for uncovered branches.

**Output:** Test run results, coverage percentages.

### 9. Report Results

Produce output in FORMAT.md structure:
1. Summary (pass/fail, coverage headline, critical issues)
2. Test Files Created table
3. Mock Implementations table
4. Test Results Summary (total/passed/failed/skipped + race status)
5. Coverage Report (per package)
6. Quality Checklist
7. Issues & Recommendations

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] Every acceptance criterion from PRD has at least one corresponding test case
- [ ] Every exported function has at least one test
- [ ] Table-driven tests used for functions with multiple scenarios
- [ ] Success AND error paths tested for every function
- [ ] Edge cases tested (nil inputs, empty strings, zero values, boundary values)
- [ ] Mock implementations match interface contracts exactly
- [ ] AssertExpectations called on all mocks
- [ ] Test helpers use t.Helper() for correct line numbers
- [ ] Tests pass with -race flag (no data races)
- [ ] Coverage meets per-package targets (80% service, 70% handler, 60% repo)
- [ ] Test names are descriptive ("success - creates user", not "test1")
- [ ] No test interdependence (each test is self-contained)
- [ ] Output matches FORMAT.md structure
