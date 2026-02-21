# Agent Memory

## Key Learnings

### Dry-Run Analysis Strategy
- When source files don't exist yet, build test plan from architectural specifications (API contracts, layer structure, endpoint counts)
- Calculate test counts by multiplying: (endpoints × avg test cases per endpoint type)
- Always verify interface definitions exist — mocks depend on them
- Check for custom error types in specifications — critical for error path testing

### Test Case Estimation
- **Handler tests**: 4-6 cases per GET endpoint, 6-10 cases per POST/PUT/DELETE
- **Service tests**: 5-7 cases for simple CRUD, 8-12 cases for complex business logic
- **Repository tests**: 3-5 cases per database method (success, not found, constraint violation, DB error)
- **Middleware tests**: 6-8 cases (success + all failure modes)

### Coverage Expectations
- Service layer: 80-85% achievable with table-driven tests covering all error paths
- Handler layer: 70-77% achievable (some error handling is boilerplate)
- Repository layer: 60-70% achievable (SQL query strings not executed in unit tests count as uncovered)
- Middleware: 80-90% achievable (focused scope, critical paths)

### Common Test Infrastructure Needs
- HTTP test helpers: NewRequest, WithChiURLParam, DecodeResponse, AssertStatus
- Test data factories: One factory per model with override functions
- Dependencies: testify (assert/require/mock), sqlmock, testcontainers-go
- Chi context helpers for URL param injection in handler tests

### Mock Patterns
- Repository mocks for service tests (layer below)
- Service mocks for handler tests (layer below)
- Never mock at same layer or above
- Mock interface method count drives implementation time: 5-8 methods = ~15 min per mock

### Typical Error Types to Plan For
- Validation errors (bad input)
- Not found errors (missing entity)
- Conflict errors (duplicate, constraint violation)
- Unauthorized errors (missing/invalid auth)
- Forbidden errors (user mismatch, insufficient permissions)
- Internal errors (infrastructure/DB failure)
- Context errors (cancellation, timeout)

### Test File Organization
- Place test files alongside source files (`user_service.go` → `user_service_test.go`)
- Place mock implementations alongside test files that use them (`mock_user_repo_test.go` in service/ package)
- Centralize test utilities in `internal/testutil/` for reuse across packages

### Dependencies Between Test Phases
1. Infrastructure (helpers, factories) — no dependencies
2. Repository tests — depend on repo interfaces, use sqlmock
3. Service tests — depend on service interfaces + repo mocks
4. Handler tests — depend on handler code + service mocks
5. Middleware tests — depend on middleware code + dependency mocks

### Integration Test Considerations
- Unit tests with mocks are fast (~3-5s for 150+ tests)
- Integration tests with testcontainers add 30-60s (container startup)
- Use `testing.Short()` flag to skip integration tests during rapid iteration
- Integration tests verify SQL correctness, constraints, transactions

### Estimation Formulas
- Test file count = handler files + service files + repo files + middleware files + 2 (testutil)
- Mock file count = (service interfaces + repo interfaces)
- Total test cases = (handler endpoints × 5) + (service methods × 6) + (repo methods × 4)
- Line count estimate = test cases × 35 lines per test case (including table setup)

### Risk Assessment Checklist
- Source files not yet implemented (blocking)
- Interfaces vs. concrete types (may require refactor)
- Custom error types defined (critical for error path tests)
- Database schema matches design doc (affects sqlmock queries)
- JWT library and setup (for auth middleware tests)
- Date/timezone handling (for filtering tests)
- Pagination edge cases (offset/limit validation)

### Dry-Run Output Quality Standards
- Every test file lists specific test case names (behavior-centric, not "test1")
- Mock interfaces list full method signatures
- Coverage expectations calculated per package with targets
- Infrastructure needs explicitly listed (missing files, missing dependencies)
- Risks categorized as blocking vs. complex vs. consideration
- Scope estimation includes file count, test count, line count, execution time

### Common Pitfalls to Document
- Forgetting to check `args.Get(0) == nil` before type-asserting in mocks (causes panic)
- Not calling `AssertExpectations(t)` on mocks (silently ignores unused mocks)
- Sharing mock instances between test cases (state leakage)
- Using `assert` instead of `require` for fatal setup assertions (test continues with invalid state)
- Not using `t.Helper()` in test utilities (wrong line numbers in failures)
- Hardcoding dates in factories (causes time-dependent test failures)
- Not setting Chi URL params in handler tests (causes nil pointer panics)

## References
- See `.claude/skills/qa-go/SKILL.md` for core testing patterns
- See `.claude/skills/qa-go/workflows/feature.md` for step-by-step test writing workflow
- See `.claude/skills/qa-go/FORMAT.md` for required output structure
- See `.claude/skills/qa-go/DRY_RUN.md` for dry-run behavior specification
