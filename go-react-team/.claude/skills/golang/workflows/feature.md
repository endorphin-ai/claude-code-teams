# Workflow: New Feature Implementation

Use this playbook when implementing a new feature from a PRD or design document.

## Prerequisites

Before starting, ensure you have:
- PRD or design document with API contracts and DB schema
- Access to the existing codebase (`go.mod` exists, project compiles)
- Knowledge of which resources/endpoints to implement

## Steps

### 1. Read PRD and Design Documents

Extract from the PRD:
- API endpoint contracts (method, path, request body, response body, status codes)
- Database schema (tables, columns, types, constraints, indexes, foreign keys)
- Business rules and validation requirements
- Authentication/authorization requirements per endpoint
- Pagination, filtering, sorting requirements

If the PRD references a shared API contract document, read that too. Note any ambiguities to flag as `[WARN]` in the report.

### 2. Scan Existing Codebase

Before writing any code:
- Read `go.mod` to check Go version and existing dependencies
- Scan `internal/` for existing packages and naming patterns
- Read `internal/router/router.go` (or equivalent) to understand current route structure
- Read existing handler/service/repository files to match code style
- Check `migrations/` for the latest migration sequence number
- Read `internal/model/errors.go` for existing error types
- Read `internal/handler/response.go` for existing response helpers

Match the existing code style exactly. Do not introduce new patterns that conflict with what is already there.

### 3. Define Models

Create or update `internal/model/{resource}.go`:

- Domain struct with `json` and `db` tags
- Use `uuid.UUID` for IDs (import `github.com/google/uuid`)
- Use `time.Time` for timestamps with `TIMESTAMPTZ` in PostgreSQL
- Use pointer types for nullable fields
- Add doc comment on the struct explaining what it represents

```go
// Project represents a user-owned project in the system.
type Project struct {
    ID          uuid.UUID  `json:"id" db:"id"`
    OwnerID     uuid.UUID  `json:"owner_id" db:"owner_id"`
    Name        string     `json:"name" db:"name"`
    Description *string    `json:"description,omitempty" db:"description"`
    CreatedAt   time.Time  `json:"created_at" db:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at" db:"updated_at"`
}
```

### 4. Create Database Migrations

Create migration files in `migrations/` using the next sequence number:

**Up migration** (`{seq}_{name}.up.sql`):
- `CREATE TABLE` with proper types, constraints, defaults
- `CREATE INDEX` for foreign keys and frequently queried columns
- Use `gen_random_uuid()` for UUID defaults (PostgreSQL 13+)
- Use `TIMESTAMPTZ` for timestamps, `NOT NULL DEFAULT NOW()`

**Down migration** (`{seq}_{name}.down.sql`):
- `DROP TABLE IF EXISTS {table}` (reverse the up migration)
- Drop indexes if created outside the table definition

### 5. Implement Repository Layer

Create `internal/repository/{resource}.go`:

- Struct with `*pgxpool.Pool` field
- `NewXxxRepository(db *pgxpool.Pool)` constructor
- One method per query: `List`, `GetByID`, `Create`, `Update`, `Delete`
- Use `context.Context` as first parameter on every method
- Use `pgx.Row.Scan()` for single results, `pgx.Rows` for lists
- Return `model.ErrNotFound` when `pgx.ErrNoRows` is received
- Wrap all errors: `fmt.Errorf("repository.GetByID: %w", err)`

```go
// GetByID retrieves a project by its ID.
func (r *ProjectRepository) GetByID(ctx context.Context, id uuid.UUID) (*model.Project, error) {
    var p model.Project
    err := r.db.QueryRow(ctx,
        `SELECT id, owner_id, name, description, created_at, updated_at
         FROM projects WHERE id = $1`, id,
    ).Scan(&p.ID, &p.OwnerID, &p.Name, &p.Description, &p.CreatedAt, &p.UpdatedAt)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, model.ErrNotFound
        }
        return nil, fmt.Errorf("repository.GetByID: %w", err)
    }
    return &p, nil
}
```

### 6. Implement Service Layer

Create `internal/service/{resource}.go`:

- Struct with repository dependency (injected via constructor)
- Business logic: ownership checks, duplicate detection, rule enforcement
- Input validation that goes beyond HTTP-level validation (e.g., cross-field rules, DB-dependent checks)
- Return domain error types (`model.ErrNotFound`, `model.ErrForbidden`, etc.)
- Never import `net/http` in the service package

```go
// Create creates a new project for the given owner.
func (s *ProjectService) Create(ctx context.Context, ownerID uuid.UUID, req CreateProjectInput) (*model.Project, error) {
    existing, err := s.repo.GetByName(ctx, ownerID, req.Name)
    if err != nil && !errors.Is(err, model.ErrNotFound) {
        return nil, fmt.Errorf("service.Create: checking duplicate: %w", err)
    }
    if existing != nil {
        return nil, fmt.Errorf("project with name %q: %w", req.Name, model.ErrConflict)
    }
    return s.repo.Create(ctx, ownerID, req.Name, req.Description)
}
```

### 7. Implement Handlers

Create `internal/handler/{resource}.go`:

- Struct with service dependency (injected via constructor)
- One method per endpoint: matches HTTP method + path
- Parse path params with `chi.URLParam(r, "id")`
- Decode and validate request body using shared `decodeAndValidate` helper
- Call service method
- Map service errors to HTTP status codes
- Write JSON response using shared response helpers
- Doc comment on each method stating the endpoint it handles

```go
// Create handles POST /api/v1/projects.
func (h *ProjectHandler) Create(w http.ResponseWriter, r *http.Request) {
    req, err := decodeAndValidate[CreateProjectRequest](r)
    if err != nil {
        respondError(w, err)
        return
    }

    ownerID := middleware.UserIDFromContext(r.Context())
    project, err := h.svc.Create(r.Context(), ownerID, toCreateInput(req))
    if err != nil {
        respondError(w, err)
        return
    }

    respondJSON(w, http.StatusCreated, toProjectResponse(project))
}
```

### 8. Wire Routes in Router

Update `internal/router/router.go`:

- Add constructor parameter for the new handler
- Register routes under the appropriate path prefix
- Apply middleware (auth, etc.) to the route group
- Follow existing grouping patterns

```go
r.Route("/projects", func(r chi.Router) {
    r.Get("/", projectH.List)
    r.Post("/", projectH.Create)
    r.Route("/{id}", func(r chi.Router) {
        r.Get("/", projectH.GetByID)
        r.Put("/", projectH.Update)
        r.Delete("/", projectH.Delete)
    })
})
```

### 9. Add Middleware as Needed

If the feature requires new middleware:
- Create `internal/middleware/{name}.go`
- Follow the `func(next http.Handler) http.Handler` pattern
- Add to the middleware chain in the router at the correct position
- Common additions: rate limiting, request size limiting, resource-specific auth

### 10. Update Dependency Injection

Update `cmd/server/main.go`:
- Instantiate the new repository, service, and handler
- Pass the handler to the router constructor
- Follow the existing wiring order

### 11. Build Verification

Run and capture output:

```bash
go build ./...
go vet ./...
```

If `golangci-lint` is available in the project, also run:

```bash
golangci-lint run ./...
```

Fix any errors before proceeding. If errors cannot be resolved, document them as `[CRITICAL]` issues.

### 12. Report Results

Produce output following FORMAT.md exactly:
1. Summary (1-3 sentences)
2. Files Created/Modified table
3. Code Summary (packages, endpoints, models)
4. Build Verification output
5. Dependencies Added
6. Issues & Recommendations
7. Quality Checklist (all items checked)

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] PRD requirements fully addressed
- [ ] All layers implemented (model -> repository -> service -> handler -> router)
- [ ] Migrations created (up + down)
- [ ] Error handling with wrapping at every layer
- [ ] Request validation with proper tags
- [ ] Proper HTTP status codes (201 for create, 204 for delete, etc.)
- [ ] Doc comments on all exported types and functions
- [ ] `go build ./...` passes
- [ ] `go vet ./...` passes
- [ ] Output matches FORMAT.md
- [ ] No files modified outside scope
