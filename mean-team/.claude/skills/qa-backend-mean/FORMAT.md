# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Summary
1-3 sentences: number of test suites created, total test cases, overall pass rate, and coverage percentage.

### 2. Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| server/tests/auth.test.js | Auth endpoint tests (register, login, me) | created |
| server/tests/posts.test.js | Post CRUD endpoint tests | created |
| server/tests/fixtures/users.js | Test user data fixtures | created |
| server/tests/setup.js | Test database setup and teardown | created |
| package.json | Added test script and devDependencies | modified |
```

### 3. Test Results

```markdown
| Suite | Tests | Passed | Failed | Coverage |
|-------|-------|--------|--------|----------|
| Auth (auth.test.js) | 12 | 12 | 0 | 94% |
| Posts (posts.test.js) | 18 | 16 | 2 | 87% |
| Models (models.test.js) | 8 | 8 | 0 | 91% |
| **Total** | **38** | **36** | **2** | **90%** |
```

### 4. Test Coverage Summary

```markdown
| Category | Files | Lines | Functions | Branches |
|----------|-------|-------|-----------|----------|
| Models | 95% | 92% | 100% | 85% |
| Controllers | 88% | 85% | 90% | 78% |
| Middleware | 100% | 100% | 100% | 100% |
| Routes | 90% | 88% | 95% | 80% |
| **Overall** | **90%** | **88%** | **93%** | **82%** |
```

### 5. Failed Tests (if any)

```markdown
| Suite | Test Case | Expected | Actual | Notes |
|-------|-----------|----------|--------|-------|
| Posts | should return 403 for non-owner update | 403 status | 200 status | Owner check not implemented in controller |
| Posts | should paginate results | 20 items | 50 items | Pagination middleware not applied |
```

### 6. Dependencies Added

```markdown
| Package | Version | Purpose | Type |
|---------|---------|---------|------|
| jest | ^29.x | Test runner | devDependency |
| supertest | ^6.x | HTTP assertion library | devDependency |
| mongodb-memory-server | ^9.x | In-memory MongoDB for tests | devDependency |
```

### 7. Quality Checklist

- [ ] Every API endpoint has at least one success and one error test case
- [ ] Auth endpoints tested: register, login, invalid credentials, duplicate email
- [ ] Protected endpoints tested: with valid token, without token, with expired token
- [ ] CRUD operations tested: create, read (single + list), update, delete
- [ ] Owner-only operations tested: own resource vs other user's resource
- [ ] Input validation tested: missing fields, invalid types, boundary values
- [ ] Edge cases tested: empty database, nonexistent IDs, malformed ObjectIds
- [ ] Test database isolated (mongodb-memory-server or separate test DB)
- [ ] Fixtures provide consistent test data
- [ ] Coverage meets minimum threshold (80%+)

### 8. Issues & Recommendations

```markdown
1. [FAIL] 2 tests failing in posts suite — owner authorization not enforced in controller
2. [COVERAGE] Branch coverage at 78% for controllers — missing error path tests
3. [FLAKY] auth.test.js occasionally times out on CI — increase Jest timeout or optimize setup
```
