# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Summary

One to three sentences describing what was tested, the overall result, and any critical findings.

```
Wrote 26 tests across 6 files covering user and project CRUD operations.
All tests pass with -race flag. Coverage at 82% for services, 75% for handlers, 63% for repositories.
One critical issue: untested error path in ProjectService.Delete when user lacks permissions.
```

### 2. Test Files Created/Modified

| File | Tests Count | Layer | Coverage Target | Status |
|------|-------------|-------|-----------------|--------|
| `internal/handler/user_handler_test.go` | 8 | handler | 70% | created |
| `internal/handler/project_handler_test.go` | 6 | handler | 70% | created |
| `internal/service/user_service_test.go` | 12 | service | 80% | created |
| `internal/service/project_service_test.go` | 10 | service | 80% | created |
| `internal/repository/user_repo_test.go` | 6 | repository | 60% | created |
| `internal/repository/project_repo_test.go` | 4 | repository | 60% | created |
| `internal/testutil/helpers.go` | - | utility | - | created |
| `internal/testutil/factories.go` | - | utility | - | created |

Use `created` for new files, `modified` for existing files with additions.

### 3. Mock Implementations Created

| Mock Type | Interface | Methods | File |
|-----------|-----------|---------|------|
| `MockUserRepository` | `repository.UserRepository` | GetByID, GetByEmail, Create, Update, Delete, List | `internal/service/mock_user_repo_test.go` |
| `MockUserService` | `service.UserService` | GetByID, Create, Update, Delete, List | `internal/handler/mock_user_svc_test.go` |
| `MockProjectRepository` | `repository.ProjectRepository` | GetByID, Create, List | `internal/service/mock_project_repo_test.go` |

### 4. Test Results Summary

```
Test Results:
- Total:   46
- Passed:  44
- Failed:   1
- Skipped:  1

Duration: 1.8s
Race detector: CLEAN (no data races detected)
```

If any tests failed, list them with details:

```
FAILED:
  - TestProjectService_Delete/error_-_insufficient_permissions
    Expected: ErrForbidden
    Actual:   nil (no error returned)
    File: internal/service/project_service_test.go:142
    Cause: Delete method does not check user permissions before deletion

SKIPPED:
  - TestUserRepository_Integration (reason: -short flag, skipping integration tests)
```

### 5. Coverage Report

```
| Package                 | Coverage | Target | Status |
|-------------------------|----------|--------|--------|
| internal/handler        | 75.2%    | 70%    | PASS   |
| internal/service        | 82.1%    | 80%    | PASS   |
| internal/repository     | 63.4%    | 60%    | PASS   |
| internal/middleware      | 85.0%    | 80%    | PASS   |

Overall: 76.4%
```

Status values: `PASS` (meets target), `FAIL` (below target), `WARN` (within 5% of target).

### 6. Quality Checklist

```markdown
- [x] Table-driven tests used for all functions with multiple scenarios
- [x] Testify assertions used (require for fatal, assert for non-fatal)
- [x] Mock interfaces created at layer boundaries
- [x] AssertExpectations called on all mocks
- [x] Success and error paths tested for every function
- [x] Tests pass with -race flag (no data races)
- [x] Each test is self-contained (no shared mutable state)
- [x] Test helpers use t.Helper() for correct line reporting
- [x] Coverage targets met per package
- [ ] Edge cases tested (nil inputs, empty strings, max-length values)
```

### 7. Issues & Recommendations

List any issues, categorized by severity:

```
[CRITICAL] internal/service/project_service.go:89 — Delete method does not check user permissions.
           Missing test for unauthorized deletion. This is a security gap.

[WARN]     internal/repository/user_repo.go:45 — Coverage at 63.4%, near the 60% threshold.
           Add test for List with pagination and sorting parameters.

[WARN]     internal/handler/project_handler.go:22 — Missing test for request body exceeding max size.
           Add test with body > 1MB to verify rejection.

[INFO]     internal/service/user_service.go:112 — Email validation logic is complex.
           Consider extracting validation to a separate function with its own unit tests.

[INFO]     Consider adding integration tests with testcontainers for repository layer
           to complement sqlmock unit tests with real PostgreSQL queries.
```

## Output Example

```
## Summary

Wrote 18 tests across 4 files for the authentication feature (login, register, token refresh).
All tests pass with -race flag. Coverage: services 88%, handlers 74%. No critical issues.

## Test Files Created

| File | Tests Count | Layer | Coverage Target | Status |
|------|-------------|-------|-----------------|--------|
| `internal/handler/auth_handler_test.go` | 6 | handler | 70% | created |
| `internal/service/auth_service_test.go` | 10 | service | 80% | created |
| `internal/repository/user_repo_test.go` | 2 | repository | 60% | modified |
| `internal/testutil/factories.go` | - | utility | - | created |

## Mock Implementations

| Mock Type | Interface | Methods | File |
|-----------|-----------|---------|------|
| `MockAuthService` | `service.AuthService` | Login, Register, RefreshToken, ValidateToken | `internal/handler/mock_auth_svc_test.go` |
| `MockUserRepository` | `repository.UserRepository` | GetByEmail, Create | `internal/service/mock_user_repo_test.go` |

## Test Results

- Total: 18
- Passed: 18
- Failed: 0
- Skipped: 0

Duration: 0.9s
Race detector: CLEAN

## Coverage

| Package | Coverage | Target | Status |
|---------|----------|--------|--------|
| internal/handler | 74.1% | 70% | PASS |
| internal/service | 88.3% | 80% | PASS |
| internal/repository | 61.2% | 60% | PASS |

Overall: 74.5%

## Quality Checklist

- [x] Table-driven tests used
- [x] Testify assertions (require/assert)
- [x] Mock interfaces at boundaries
- [x] AssertExpectations called
- [x] Success + error paths tested
- [x] Race-clean
- [x] Self-contained tests
- [x] t.Helper() in helpers
- [x] Coverage targets met

## Issues & Recommendations

[WARN]  auth_handler.go:55 — Token refresh endpoint not tested with expired refresh token.
        Add test case for expired refresh token returning 401.
[INFO]  auth_service.go:78 — Password hashing uses bcrypt with cost 10.
        Consider adding benchmark test to verify hashing performance under load.
[INFO]  Consider adding rate limiting tests for login endpoint (brute force protection).
```
