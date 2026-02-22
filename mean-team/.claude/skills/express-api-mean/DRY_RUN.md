# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze
- Read the PRD to extract all features and their required operations (CRUD, auth, search, etc.)
- Map each feature to REST endpoints (method + path)
- Identify auth requirements per endpoint from PRD acceptance criteria
- Check for existing route files, middleware, and controllers in the codebase
- Read the database schema docs to understand available models and fields

## What to Output

### 1. Endpoint Inventory

```markdown
| Method | Endpoint | PRD Feature | Auth | Complexity |
|--------|----------|-------------|------|------------|
| POST | /api/users/register | F1 | Public | Low |
| POST | /api/users/login | F2 | Public | Medium |
| GET | /api/posts | F3 | Authenticated | Medium |
| POST | /api/posts | F4 | Authenticated | Low |
```

### 2. Resource Map

```markdown
| Resource | Endpoints | Model Dependency |
|----------|-----------|-----------------|
| users | 4 endpoints | User model |
| posts | 5 endpoints | Post model, User model |
```

### 3. Auth Matrix

```markdown
| Endpoint Pattern | Public | Authenticated | Owner | Admin |
|-----------------|--------|---------------|-------|-------|
| POST /register, /login | X | | | |
| GET /posts | | X | | |
| PUT/DELETE /posts/:id | | | X | |
| GET /admin/* | | | | X |
```

### 4. Middleware Plan
- Global: cors, helmet, express.json(), errorHandler
- Auth: JWT verification middleware
- Validation: request body validation per endpoint
- Custom: any feature-specific middleware (file upload, rate limiting)

### 5. Complexity Estimate
- Total endpoints: X
- Route files: Y
- Middleware files: Z
- Estimated effort: Small / Medium / Large

## What NOT to Do
- DO NOT write full endpoint contracts (just method + path + purpose)
- DO NOT create any files on disk
- DO NOT write controller or middleware code
- DO NOT install packages or modify package.json
- DO still read the PRD, schema docs, and existing codebase to make real design decisions
