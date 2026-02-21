# Workflow: Regression Test for Bug Fix

Use this playbook when writing a regression test to cover a bug fix, or when adding tests to prevent a specific bug from recurring.

## Prerequisites

- Bug report is available (from PRD, Jira ticket, or user description)
- The bug's root cause is identified or the fix is already applied
- Go source files for the affected code are accessible

## Steps

### 1. Understand the Bug

Read the bug report and extract:

- **Affected function**: Which function(s) exhibit the bug (handler, service, or repository)
- **Trigger input**: What specific input or sequence of operations causes the bug
- **Expected behavior**: What should happen with that input
- **Actual behavior**: What currently happens (the bug)
- **Root cause**: Why the code behaves incorrectly (if known)

**Document the bug signature:**
```
Bug: User creation succeeds with duplicate email
Affected: service.UserService.Create
Trigger: POST /api/v1/users with email that already exists in DB
Expected: 409 Conflict with error "email already exists"
Actual: 201 Created (duplicate user record in DB)
Root cause: Create() does not call GetByEmail() before inserting
```

### 2. Locate Existing Tests

Check if tests already exist for the affected function:

- If `*_test.go` exists, check if the bug scenario is tested
- If the scenario exists but passes: the test is wrong or incomplete — it didn't catch the bug
- If no tests exist: create the test file following the feature workflow pattern

### 3. Write the Regression Test

Create a test case that **specifically targets the bug scenario**. The test MUST:

1. **Reproduce the exact trigger condition** — use the same input that causes the bug
2. **Assert the correct behavior** — what SHOULD happen after the fix
3. **Have a descriptive name** that references the bug:

```go
func TestUserService_Create_DuplicateEmailReturnsConflict(t *testing.T) {
    repo := new(MockUserRepository)

    // Setup: email already exists in the database
    existingUser := &model.User{
        ID:    uuid.New(),
        Email: "duplicate@example.com",
        Name:  "Existing User",
    }
    repo.On("GetByEmail", mock.Anything, "duplicate@example.com").
        Return(existingUser, nil)

    svc := service.NewUserService(repo)

    // Act: try to create a user with the same email
    err := svc.Create(context.Background(), model.CreateUserRequest{
        Email: "duplicate@example.com",
        Name:  "New User",
    })

    // Assert: should return conflict error, NOT succeed
    require.Error(t, err)
    assert.ErrorIs(t, err, model.ErrAlreadyExists)

    // Verify: Create should NOT have been called on the repository
    repo.AssertNotCalled(t, "Create", mock.Anything, mock.Anything)
    repo.AssertExpectations(t)
}
```

### 4. Verify Test Fails Without Fix (if possible)

If the fix has NOT been applied yet:

1. Run the regression test: `go test -v -run TestUserService_Create_DuplicateEmail ./internal/service/`
2. Confirm it **FAILS** — this validates the test actually catches the bug
3. If it passes: the test is not targeting the right code path — revise it

If the fix IS already applied:
- Document in the test comment what the behavior was before the fix
- Add a code comment: `// Regression: before fix, this returned nil error and created duplicate`

### 5. Verify Test Passes With Fix

After the fix is applied:

1. Run the regression test: `go test -v -run TestUserService_Create_DuplicateEmail ./internal/service/`
2. Confirm it **PASSES**
3. Run the full suite: `go test -v -race -cover ./...`
4. Confirm no other tests are broken by the fix

### 6. Add Related Edge Cases

If the bug reveals a class of untested scenarios, add additional test cases:

```go
// If the bug was about duplicate emails, also test:
{
    name: "error - duplicate email case-insensitive",
    input: model.CreateUserRequest{Email: "DUPLICATE@Example.COM"},
    // Should still detect as duplicate
},
{
    name: "error - duplicate email with whitespace",
    input: model.CreateUserRequest{Email: "  duplicate@example.com  "},
    // Should trim and detect as duplicate
},
```

**Rule:** A bug is evidence of an untested category. Don't just test the exact scenario — test the entire category of similar inputs.

### 7. Run Full Suite

```bash
go test -v -race -cover ./...
```

Verify:
- [ ] Regression test passes
- [ ] All existing tests still pass
- [ ] No new data races introduced
- [ ] Coverage improved or maintained

### 8. Report Results

Produce output in FORMAT.md structure:

Include these additional sections specific to bug fix testing:

```
## Bug Fix Verification

Bug: [description]
Affected: [function]
Regression Test: [test function name]
Result: PASSES (confirms fix works)

## Related Edge Cases Added

| Test Case | Scenario | Status |
|-----------|----------|--------|
| TestUserService_Create_DuplicateEmailCaseInsensitive | Case-insensitive email matching | PASS |
| TestUserService_Create_DuplicateEmailWhitespace | Email with leading/trailing spaces | PASS |
```

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] Bug report read and understood — trigger input and expected behavior documented
- [ ] Regression test specifically targets the bug scenario
- [ ] Test name clearly describes the bug (e.g., `TestUserService_Create_DuplicateEmailReturnsConflict`)
- [ ] Test would fail without the fix (verified or documented)
- [ ] Test passes with the fix
- [ ] Related edge cases from the same bug category added
- [ ] No existing tests broken by the fix
- [ ] Race-clean (`go test -race`)
- [ ] Bug fix comment added in the test (what the behavior was before the fix)
- [ ] Output matches FORMAT.md structure
