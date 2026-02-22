# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze
- Scan backend code for all testable endpoints (routes + controllers)
- Scan models for validation logic, hooks, and methods that need testing
- Scan middleware for auth, validation, and error handling functions
- Check for existing test files, test configuration, and test dependencies
- Read API design docs to understand expected request/response contracts

## What to Output

### 1. Test Inventory

```markdown
| Suite | Source File | Test Cases Planned | Priority |
|-------|-----------|-------------------|----------|
| Auth | controllers/userController.js | 12 (register: 4, login: 4, me: 4) | High |
| Posts | controllers/postController.js | 18 (CRUD: 12, auth: 4, edge: 2) | High |
| Models | models/User.js, Post.js | 8 (validation: 4, hooks: 2, methods: 2) | Medium |
| Middleware | middleware/auth.js | 5 (valid: 1, invalid: 2, missing: 1, expired: 1) | High |
```

### 2. Fixture Plan

```markdown
| Fixture | Purpose | Data |
|---------|---------|------|
| validUser | Standard authenticated user | email, hashed password, role: user |
| adminUser | Admin role user | email, hashed password, role: admin |
| validPost | Standard post document | title, body, author: validUser._id |
| invalidToken | Expired/malformed JWT | expired token string |
```

### 3. Setup Requirements
- Test database: mongodb-memory-server (in-memory) or separate test MongoDB instance
- Test runner: Jest with supertest for HTTP assertions
- Environment: separate .env.test with test-specific values
- Pre-run: seed database with fixtures before each suite
- Post-run: drop database after each suite

### 4. Coverage Targets

```markdown
| Category | Target | Rationale |
|----------|--------|-----------|
| Controllers | 85%+ | Core business logic |
| Models | 90%+ | Data integrity critical |
| Middleware | 95%+ | Security-critical code |
| Routes | 80%+ | Mostly wiring, less logic |
| Overall | 85%+ | Industry standard for APIs |
```

### 5. Risk Areas
1. [COVERAGE] Auth middleware has 4 code paths — all must be tested for security
2. [FLAKY] Database-dependent tests need proper setup/teardown isolation
3. [FAIL] If controllers lack error handling, error-path tests will fail and expose bugs

## What NOT to Do
- DO NOT write test code (describe blocks, it blocks, assertions)
- DO NOT create any files on disk
- DO NOT run `npm install` or `npm test`
- DO NOT modify package.json or jest configuration
- DO still scan the backend codebase to make real testing decisions
