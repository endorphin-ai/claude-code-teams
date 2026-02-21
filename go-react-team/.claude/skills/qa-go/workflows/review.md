# Workflow: Test Review

Use this playbook when reviewing existing test code for quality, coverage, correctness, and adherence to Go testing best practices.

## Prerequisites

- Test files exist in the codebase (`*_test.go` files)
- Go source files are available for cross-referencing
- `go test ./...` runs without build errors

## Steps

### 1. Inventory Test Files

- Scan all `*_test.go` files in scope
- For each test file, list:
  - Test functions (names starting with `Test`)
  - Benchmark functions (names starting with `Benchmark`)
  - Helper functions
  - Mock implementations
- Cross-reference with source files to identify untested functions

**Output:** Complete inventory of test files and untested source functions.

### 2. Check Coverage

Run `go test -cover ./...` and analyze per-package coverage:

| Package | Current Coverage | Target | Status |
|---------|-----------------|--------|--------|
| internal/handler | 72% | 70% | PASS |
| internal/service | 78% | 80% | WARN |
| internal/repository | 55% | 60% | FAIL |

For packages below target:
- Identify specific functions with 0% or low coverage
- List which code paths (branches) are not exercised
- Recommend specific test cases to add

**Output:** Coverage report with gap analysis.

### 3. Check Table-Driven Test Pattern

For each test function, verify:

- [ ] Uses `[]struct` with `name` field for test cases
- [ ] Uses `t.Run(tt.name, func(t *testing.T) { ... })` for subtests
- [ ] Has at least 1 success case + 2 error cases
- [ ] Test case names are descriptive (not "test1", "case2")
- [ ] Captures range variable with `tt := tt` if using `t.Parallel()`

**Flag violations:**
```
[WARN] TestUserService_Create — not table-driven, has 3 separate test functions instead
       Recommendation: Consolidate into a single table-driven test with subtests

[WARN] TestProjectHandler_GetByID — table test missing error cases
       Only tests success path. Add: invalid UUID, not found, internal error
```

### 4. Check Assertion Quality

For each test, verify:

- [ ] Uses `testify/require` for fatal setup assertions (DB connection, mock setup)
- [ ] Uses `testify/assert` for non-fatal test assertions (value comparisons)
- [ ] Does NOT use bare `if err != nil { t.Fatal(err) }` — use `require.NoError`
- [ ] Does NOT use `reflect.DeepEqual` — use `assert.Equal` or `assert.EqualValues`
- [ ] Assertions are specific:
  - Good: `assert.Equal(t, "john@test.com", user.Email)`
  - Bad: `assert.NotNil(t, user)` (too vague — what if Email is wrong?)
- [ ] Error assertions use `assert.ErrorIs` or `assert.ErrorAs` (not string matching)

**Flag violations:**
```
[WARN] TestUserService_Create/success — only asserts err == nil, doesn't verify returned user
[CRITICAL] TestAuthHandler_Login — uses string matching on error message instead of ErrorIs
```

### 5. Check Mock Quality

For each mock implementation, verify:

- [ ] Mock implements the full interface (all methods)
- [ ] `AssertExpectations(t)` is called at the end of every test using the mock
- [ ] Mocks are created fresh per test (no shared mock instances)
- [ ] Mocks are at interface boundaries only:
  - Handlers mock services ✓
  - Services mock repositories ✓
  - Services mock services ✗ (layer violation)
  - Handlers mock repositories ✗ (layer skipping)
- [ ] `mock.Anything` used for `context.Context` (not specific context values)
- [ ] Pointer returns check `args.Get(0) == nil` before type assertion

**Flag violations:**
```
[CRITICAL] TestProjectHandler_Create — mocks repository directly, skipping service layer
           Fix: Mock service.ProjectService instead of repository.ProjectRepository

[WARN] TestUserService_Update — AssertExpectations not called
       Fix: Add repo.AssertExpectations(t) at end of each subtest
```

### 6. Check Test Independence

Verify no test depends on another test's state:

- [ ] No package-level mutable variables shared between tests
- [ ] No test relies on execution order
- [ ] `t.Parallel()` used where safe (no shared state)
- [ ] Each test creates its own mock instances and test data
- [ ] No `TestMain` with setup that persists between tests (unless integration test with explicit cleanup)
- [ ] No global database state assumptions

**Detection:** Run tests with `-count=2 -shuffle=on` to catch order dependencies.

```
[CRITICAL] TestUserService_Delete depends on TestUserService_Create having run first
           Shared package-level variable `createdUserID` modified across tests
           Fix: Create user within Delete test setup, don't rely on Create test
```

### 7. Check Error Path Coverage

For each tested function, verify error paths are covered:

- [ ] Every `if err != nil { return }` has a test that triggers it
- [ ] Every custom error type has a test that returns it
- [ ] Every validation branch has a test with invalid input
- [ ] HTTP handlers test at minimum: 200, 400, 404, 500

**Gap analysis format:**
```
internal/service/user_service.go:
  Create():
    ✓ Line 23: GetByEmail returns ErrNotFound → tested
    ✓ Line 28: GetByEmail returns duplicate → tested
    ✗ Line 35: repository.Create returns error → UNTESTED
    ✗ Line 42: password hash fails → UNTESTED
```

### 8. Check HTTP Handler Test Quality

For handler tests specifically:

- [ ] Chi URL params set correctly using `chi.NewRouteContext()` + `URLParams.Add()`
- [ ] Request body set with `strings.NewReader` or `bytes.NewBuffer`
- [ ] Content-Type header set for POST/PUT requests
- [ ] Response status code checked
- [ ] Response body decoded and validated (not just status code)
- [ ] Both JSON structure and field values verified

**Flag:**
```
[WARN] TestUserHandler_Create — only checks status code 201, does not verify response body
       Fix: Decode response and assert returned user has correct email and name
```

### 9. Check Race Safety

- [ ] No tests flagged by `go test -race`
- [ ] No goroutines spawned in tests without synchronization
- [ ] No writes to shared maps without mutex
- [ ] `t.Parallel()` tests properly capture range variables

Run: `go test -race -count=1 ./...`

### 10. Report Results

Produce output in FORMAT.md structure:
- Summary of review findings
- Coverage analysis table
- Issues categorized by severity ([CRITICAL], [WARN], [INFO])
- Specific recommendations for each issue

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] All `*_test.go` files in scope reviewed
- [ ] Coverage gaps identified with specific function/line recommendations
- [ ] Table-driven test pattern verified for all multi-scenario functions
- [ ] Assertion quality verified (no bare if checks, specific assertions)
- [ ] Mock quality verified (interface boundaries, AssertExpectations)
- [ ] Test independence verified (no shared mutable state, order independence)
- [ ] Error paths inventoried with tested/untested markings
- [ ] Handler tests verify status codes AND response bodies
- [ ] Race safety verified with -race flag
- [ ] Issues categorized by severity ([CRITICAL], [WARN], [INFO])
- [ ] Output matches FORMAT.md structure
