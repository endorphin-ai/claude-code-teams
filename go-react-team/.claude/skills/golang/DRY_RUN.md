# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze

Perform all of these steps for real -- read actual files, make actual decisions:

1. **Read PRD and design docs** -- Extract API contracts, DB schema, business rules. Identify every endpoint and model needed.
2. **Scan existing codebase** -- Read `go.mod` for current dependencies. Scan `internal/` for existing packages, models, handlers. Identify integration points.
3. **Determine project structure** -- Map out which packages exist, which need creation, which need modification.
4. **Identify migration sequence** -- Read existing migrations in `migrations/` to determine the next sequence number and avoid conflicts.
5. **Check for conflicts** -- Identify naming collisions, import cycles, or duplicate route registrations.
6. **Evaluate dependencies** -- Determine if new `go.mod` additions are needed and justify each.

## What to Output

Produce the full FORMAT.md output structure, but replace actual code with plans:

### File Plan

List every file that WOULD be created or modified:

```markdown
| File | Purpose | Action | Complexity |
|------|---------|--------|------------|
| `internal/model/project.go` | Project struct with JSON/DB tags | create | low |
| `internal/repository/project.go` | CRUD queries for projects table | create | medium |
| `internal/service/project.go` | Ownership validation, business rules | create | medium |
| `internal/handler/project.go` | HTTP handlers for /api/v1/projects | create | medium |
| `internal/router/router.go` | Register project routes | modify | low |
| `migrations/000003_create_projects.up.sql` | CREATE TABLE projects | create | low |
| `migrations/000003_create_projects.down.sql` | DROP TABLE projects | create | low |
```

### Package Structure

Show the package dependency graph:

```
cmd/server/main.go
  -> internal/config
  -> internal/router
    -> internal/handler
      -> internal/service
        -> internal/repository
          -> internal/model
    -> internal/middleware
```

### Endpoint Stubs

List every endpoint with its full call chain:

```markdown
- `GET    /api/v1/projects`       -> ProjectHandler.List    -> ProjectService.List    -> ProjectRepository.List
- `POST   /api/v1/projects`       -> ProjectHandler.Create  -> ProjectService.Create  -> ProjectRepository.Create
- `GET    /api/v1/projects/{id}`  -> ProjectHandler.GetByID -> ProjectService.GetByID -> ProjectRepository.GetByID
- `PUT    /api/v1/projects/{id}`  -> ProjectHandler.Update  -> ProjectService.Update  -> ProjectRepository.Update
- `DELETE /api/v1/projects/{id}`  -> ProjectHandler.Delete  -> ProjectService.Delete  -> ProjectRepository.Delete
```

### Model Definitions

Define structs without writing files:

```go
// Would be created in internal/model/project.go
type Project struct {
    ID          uuid.UUID  `json:"id" db:"id"`
    OwnerID     uuid.UUID  `json:"owner_id" db:"owner_id"`
    Name        string     `json:"name" db:"name"`
    Description string     `json:"description" db:"description"`
    CreatedAt   time.Time  `json:"created_at" db:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at" db:"updated_at"`
}
```

### Migration SQL

Show the SQL that would be in migration files:

```sql
-- Would be migrations/000003_create_projects.up.sql
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_projects_owner_id ON projects(owner_id);
```

### Dependencies

List any new `go.mod` additions that would be needed and why.

### Architecture Decisions

Document any non-obvious choices:

```markdown
- Using UUID v7 for project IDs (sortable, unique)
- Soft delete not implemented (PRD does not mention it)
- Pagination uses cursor-based approach for List endpoint
```

### Risks & Concerns

```markdown
- [WARN] No unique constraint on project name per owner -- PRD is ambiguous on this
- [INFO] Consider adding updated_at trigger in PostgreSQL for automatic timestamps
```

### Scope Estimate

```markdown
- Files to create: 7
- Files to modify: 1
- New endpoints: 5
- New models: 4 (1 domain + 3 request/response)
- Estimated complexity: Medium
```

## What NOT to Do

- DO NOT create, modify, or delete any files
- DO NOT run `go mod tidy`, `go build`, or any build commands
- DO NOT install packages or modify `go.mod`
- DO NOT create migration files
- DO NOT modify router registrations
- DO still read skills, scan the codebase, and make real architectural decisions
- DO still produce the full FORMAT.md structure with plans in place of code
