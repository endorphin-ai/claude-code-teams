# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output -- deviations break the pipeline.

This skill has TWO output formats depending on operating mode. Use the correct one.

---

## Design Mode Output (Phase 1)

Use this format when producing a system design document from a PRD.

### 1. Summary

2-3 sentences describing what is being designed, the scope, and key architectural decisions.

### 2. API Endpoints

```markdown
| Method | Path | Request Body | Response Body | Status Codes | Description |
|--------|------|-------------|---------------|--------------|-------------|
| GET | /api/v1/users | -- | ListResponse[UserResponse] | 200, 401 | List all users with pagination |
| POST | /api/v1/users | CreateUserRequest | UserResponse | 201, 400, 409 | Create a new user |
| GET | /api/v1/users/{id} | -- | UserResponse | 200, 404 | Get user by ID |
| PUT | /api/v1/users/{id} | UpdateUserRequest | UserResponse | 200, 400, 404 | Update user |
| DELETE | /api/v1/users/{id} | -- | -- | 204, 404 | Soft-delete user |
```

For each endpoint, also define the request/response types:

```markdown
#### CreateUserRequest
| Field | Type | Required | Validation |
|-------|------|----------|------------|
| email | string | yes | valid email, unique |
| name | string | yes | 2-100 chars |
| password | string | yes | min 8 chars |

#### UserResponse
| Field | Type | Description |
|-------|------|-------------|
| id | uuid | User ID |
| email | string | User email |
| name | string | Display name |
| created_at | datetime | ISO 8601 UTC |
| updated_at | datetime | ISO 8601 UTC |
```

### 3. Database Schema

Full CREATE TABLE statements with indexes, constraints, and triggers:

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users (email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_active ON users (id) WHERE deleted_at IS NULL;

CREATE TRIGGER set_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();
```

Include an Entity Relationship summary:

```markdown
#### Entity Relationships
- users 1--* projects (user_id FK)
- projects 1--* tasks (project_id FK)
- users *--* roles (via user_roles junction)
```

### 4. Component Tree

ASCII hierarchy showing React components, their type, and key props:

```
src/
  App.tsx
    AuthProvider (context: user, login, logout)
      Layout.tsx
        Header.tsx (props: user: User | null)
        Sidebar.tsx (props: menuItems: MenuItem[])
        <Outlet />
          pages/
            UsersPage.tsx (fetches: useUsers query)
              UserList.tsx (props: users: User[], onSelect: (id) => void)
                UserCard.tsx (props: user: User)
              UserFilters.tsx (props: filters: FilterState, onChange: (f) => void)
            UserDetailPage.tsx (fetches: useUser(id) query)
              UserProfile.tsx (props: user: User)
              UserEditForm.tsx (props: user: User, onSubmit: (data) => void)
```

### 5. Go Project Structure

Directory tree with file purposes:

```
cmd/
  server/
    main.go                          # Wires config, DB, services, router, starts HTTP server
internal/
  config/
    config.go                        # Loads from env: DB_URL, PORT, JWT_SECRET
  handler/
    user_handler.go                  # Handlers: ListUsers, GetUser, CreateUser, UpdateUser, DeleteUser
    auth_handler.go                  # Handlers: Login, Register, RefreshToken
    middleware.go                    # AuthMiddleware, LoggingMiddleware, CORSMiddleware
  service/
    user_service.go                  # Business logic: validate unique email, hash password
    auth_service.go                  # JWT generation, token validation, password verification
  repository/
    user_repository.go               # CRUD queries for users table
  model/
    user.go                          # User struct, UserFilter, UserStatus enum
    errors.go                        # ErrNotFound, ErrAlreadyExists, ErrForbidden
  dto/
    user_dto.go                      # CreateUserRequest, UpdateUserRequest, UserResponse
    auth_dto.go                      # LoginRequest, TokenResponse
    validation.go                    # Shared validation helpers
  router/
    router.go                        # Route group: /api/v1/users, /api/v1/auth
pkg/
  response/
    response.go                      # JSON(), Error(), Paginated() helpers
  pagination/
    pagination.go                    # ParsePagination(r), PaginationResponse struct
migrations/
  001_create_users.up.sql
  001_create_users.down.sql
```

### 6. Integration Points

```markdown
#### Frontend <-> Backend
- All API calls via `src/api/client.ts` using fetch/axios
- Auth token stored in httpOnly cookie or localStorage
- API base URL from environment variable VITE_API_URL

#### Backend <-> Database
- Connection via `database/sql` + `lib/pq` driver
- Connection pool: max 25 open, max 5 idle, 5min lifetime
- Migrations run on startup or via CLI command

#### Cross-Cutting Concerns
- CORS: Allow frontend origin, credentials: true
- Auth: JWT in Authorization header, middleware validates
- Logging: Structured JSON logs (zerolog or slog)
- Errors: Standardized error envelope on all error responses
```

### 7. Quality Checklist

```markdown
- [ ] Every PRD requirement has at least one API endpoint
- [ ] Every endpoint has defined request/response types
- [ ] Every entity has a DB table with proper indexes
- [ ] Every table has id, created_at, updated_at columns
- [ ] Foreign keys have ON DELETE clauses
- [ ] Component tree covers all UI requirements from PRD
- [ ] Go project follows handler -> service -> repository pattern
- [ ] No circular dependencies in the design
```

### 8. Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| docs/design.md | System design document | created |
| api/openapi.yaml | OpenAPI specification | created |
```

---

## Review Mode Output (Phase 4)

Use this format when reviewing implemented code against the design document.

### 1. Summary

2-3 sentences: what was reviewed, scope of review, overall verdict.

### 2. Conformance Matrix

Endpoint-by-endpoint check against the design document:

```markdown
| Design Endpoint | Implemented | File | Method Match | Path Match | Request Match | Response Match | Status Codes Match |
|----------------|-------------|------|-------------|------------|--------------|---------------|-------------------|
| GET /api/v1/users | YES | internal/handler/user_handler.go:45 | OK | OK | OK | OK | OK |
| POST /api/v1/users | YES | internal/handler/user_handler.go:78 | OK | OK | MISMATCH: missing 'role' field | OK | MISSING: 409 |
| GET /api/v1/users/{id} | NO | -- | -- | -- | -- | -- | -- |
```

### 3. DB Schema Conformance

```markdown
| Design Table | Migration File | Columns Match | Indexes Match | Constraints Match | Issues |
|-------------|----------------|--------------|--------------|------------------|--------|
| users | 001_create_users.up.sql | OK | MISSING: idx_users_email | OK | -- |
| projects | NOT FOUND | -- | -- | -- | No migration file |
```

### 4. Component Structure Conformance

```markdown
| Design Component | File Exists | Props Match | Type Correct | Issues |
|-----------------|-------------|------------|--------------|--------|
| UsersPage | src/pages/UsersPage.tsx | OK | Page | -- |
| UserList | src/components/UserList.tsx | MISSING: onSelect prop | Presentational | Should accept callback |
| UserCard | NOT FOUND | -- | -- | Component not created |
```

### 5. Go Pattern Conformance

```markdown
| Pattern | Status | Details |
|---------|--------|---------|
| handler -> service -> repository | OK | All handlers call services, services call repos |
| Interfaces defined in consumer | VIOLATION | UserRepository interface in repository pkg, should be in service |
| Context propagation | OK | All DB methods accept context.Context |
| Error wrapping | WARN | user_service.go:34 returns raw repo error without wrapping |
| DTO separation | OK | Request/response types in dto package |
```

### 6. Issues Found

```markdown
| # | Severity | File:Line | Description | Suggestion |
|---|----------|-----------|-------------|------------|
| 1 | CRITICAL | internal/handler/user_handler.go:92 | SQL injection: raw string concatenation in query | Use parameterized query with $1 placeholder |
| 2 | HIGH | internal/handler/user_handler.go:45 | Business logic in handler: email uniqueness check | Move to user_service.go |
| 3 | HIGH | migrations/001_create_users.up.sql | Missing index on email column | Add: CREATE INDEX idx_users_email ON users(email) |
| 4 | MEDIUM | src/pages/UsersPage.tsx:120 | Component exceeds 200 lines | Split data fetching into custom hook |
| 5 | LOW | internal/dto/user_dto.go:15 | Field 'Name' missing validate tag | Add validate:"required,min=2,max=100" |
```

### 7. Pattern Violations

List each anti-pattern detected with specific file references:

```markdown
#### Fat Handler
- `internal/handler/user_handler.go:45-67` -- Performs email uniqueness check directly.
  Should be in `internal/service/user_service.go`.

#### N+1 Query
- `internal/repository/project_repository.go:89-95` -- Fetches tasks in a loop per project.
  Should use JOIN or batch query.
```

### 8. Overall Assessment

```markdown
**Verdict:** PASS | FAIL | CONDITIONAL

**Summary:**
- Endpoints implemented: 8/10
- DB tables migrated: 4/5
- Components created: 12/15
- Critical issues: 1
- High issues: 3
- Medium issues: 5
- Low issues: 2

**Blocking Issues (must fix before merge):**
1. SQL injection in user_handler.go:92
2. Missing GET /api/v1/users/{id} endpoint

**Recommendations (fix in follow-up):**
1. Add missing indexes on FK columns
2. Extract large components into smaller units
```

### 9. Quality Checklist

```markdown
- [ ] All design endpoints checked against implementation
- [ ] All design tables checked against migrations
- [ ] All design components checked against source files
- [ ] Go layer pattern verified (handler/service/repository)
- [ ] Anti-pattern scan completed
- [ ] Issues categorized by severity
- [ ] Every issue has file:line reference and actionable suggestion
- [ ] Overall verdict determined with justification
```

### 10. Files Reviewed

```markdown
| File | Lines | Issues Found |
|------|-------|-------------|
| internal/handler/user_handler.go | 234 | 2 |
| internal/service/user_service.go | 156 | 1 |
| src/pages/UsersPage.tsx | 210 | 1 |
```
