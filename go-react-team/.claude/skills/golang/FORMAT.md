# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output -- deviations break the pipeline.

## Required Output Sections

### 1. Summary

One to three sentences describing what was implemented, fixed, or reviewed. Include the primary resource/endpoint affected.

Example: "Implemented CRUD endpoints for the `users` resource with JWT-protected routes, input validation, and PostgreSQL persistence via pgx."

### 2. Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| `internal/model/user.go` | User domain model and DB struct | created |
| `internal/repository/user.go` | User database queries (CRUD) | created |
| `internal/service/user.go` | User business logic layer | created |
| `internal/handler/user.go` | User HTTP handlers (list, get, create, update, delete) | created |
| `internal/router/router.go` | Added /api/v1/users routes | modified |
| `migrations/000002_create_users.up.sql` | Users table migration | created |
| `migrations/000002_create_users.down.sql` | Users table rollback | created |
```

Every file touched MUST appear in this table. Use project-relative paths. Status is one of: `created`, `modified`, `deleted`.

### 3. Code Summary

```markdown
**Packages:**
- `internal/model` -- added User struct with JSON/DB tags
- `internal/repository` -- added UserRepository with 5 query methods
- `internal/service` -- added UserService with business validation

**Endpoints:**
- `GET    /api/v1/users`       -- list users (paginated)
- `POST   /api/v1/users`       -- create user
- `GET    /api/v1/users/{id}`  -- get user by ID
- `PUT    /api/v1/users/{id}`  -- update user
- `DELETE /api/v1/users/{id}`  -- delete user

**Models Defined:**
- `User` (id, email, name, password_hash, created_at, updated_at)
- `CreateUserRequest` (email, name, password -- validated)
- `UpdateUserRequest` (name -- validated)
- `UserResponse` (id, email, name, created_at)
```

### 4. Build Verification

```markdown
**Build:**
$ go build ./...
OK (exit 0)

**Vet:**
$ go vet ./...
OK (exit 0)

**Lint (if available):**
$ golangci-lint run ./...
OK (exit 0)
```

If build or vet fails, include the full error output and note what needs resolution.

### 5. Dependencies Added

```markdown
| Module | Version | Purpose |
|--------|---------|---------|
| `github.com/go-chi/chi/v5` | v5.0.12 | HTTP router |
| `github.com/jackc/pgx/v5` | v5.5.5 | PostgreSQL driver |
| `github.com/go-playground/validator/v10` | v10.19.0 | Request validation |
```

If no new dependencies were added, state: "No new dependencies."

### 6. Issues & Recommendations

Report any issues discovered during implementation. Categorize by severity:

```markdown
- [CRITICAL] {Description of blocking issue that must be fixed}
- [WARN] {Description of non-blocking concern that should be addressed}
- [INFO] {Observation or suggestion for improvement}
```

If no issues: "No issues found."

## Quality Checklist

Before reporting, verify all items:

```markdown
- [ ] All files listed in Files Created/Modified table
- [ ] All endpoints listed in Code Summary
- [ ] `go build ./...` passes
- [ ] `go vet ./...` passes
- [ ] All exported functions have doc comments
- [ ] Error handling uses `fmt.Errorf("context: %w", err)` wrapping
- [ ] No business logic in handlers
- [ ] No HTTP concepts in repositories
- [ ] Request/response structs have validation tags
- [ ] Proper HTTP status codes used
```

## Output Example

```
## Summary

Implemented CRUD API for the `projects` resource with paginated listing, ownership validation, and PostgreSQL persistence.

## Files Created/Modified

| File | Purpose | Status |
|------|---------|--------|
| `internal/model/project.go` | Project domain model | created |
| `internal/repository/project.go` | Project DB queries | created |
| `internal/service/project.go` | Project business logic | created |
| `internal/handler/project.go` | Project HTTP handlers | created |
| `internal/router/router.go` | Added /api/v1/projects routes | modified |
| `migrations/000003_create_projects.up.sql` | Projects table | created |
| `migrations/000003_create_projects.down.sql` | Projects table rollback | created |

## Code Summary

**Packages:**
- `internal/model` -- added Project struct
- `internal/repository` -- added ProjectRepository with 5 methods
- `internal/service` -- added ProjectService with ownership checks

**Endpoints:**
- `GET    /api/v1/projects`       -- list user's projects (paginated)
- `POST   /api/v1/projects`       -- create project
- `GET    /api/v1/projects/{id}`  -- get project by ID
- `PUT    /api/v1/projects/{id}`  -- update project (owner only)
- `DELETE /api/v1/projects/{id}`  -- delete project (owner only)

**Models Defined:**
- `Project` (id, owner_id, name, description, created_at, updated_at)
- `CreateProjectRequest` (name, description)
- `UpdateProjectRequest` (name, description)
- `ProjectResponse` (id, name, description, created_at)

## Build Verification

**Build:**
$ go build ./...
OK (exit 0)

**Vet:**
$ go vet ./...
OK (exit 0)

## Dependencies Added

No new dependencies.

## Issues & Recommendations

- [INFO] Consider adding database indexes on `projects.owner_id` for query performance.

## Quality Checklist

- [x] All files listed in Files Created/Modified table
- [x] All endpoints listed in Code Summary
- [x] `go build ./...` passes
- [x] `go vet ./...` passes
- [x] All exported functions have doc comments
- [x] Error handling uses wrapping
- [x] No business logic in handlers
- [x] No HTTP concepts in repositories
- [x] Validation tags on request structs
- [x] Proper HTTP status codes
```
