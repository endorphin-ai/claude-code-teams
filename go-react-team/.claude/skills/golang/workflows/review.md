# Workflow: Code Review

Use this playbook when performing a self-review or peer review of Go backend code.

## Prerequisites

Before starting, ensure you have:
- List of files in scope for review (or a commit range / PR reference)
- Access to the full codebase for context

## Steps

### 1. Gather Files in Scope

Identify all Go files to review. If reviewing a feature implementation, include:
- All files in `internal/model/`, `internal/repository/`, `internal/service/`, `internal/handler/` related to the feature
- Router modifications in `internal/router/`
- Migration files in `migrations/`
- Any new middleware in `internal/middleware/`
- Changes to `cmd/server/main.go` (DI wiring)

### 2. Review Each Layer

Review files layer by layer, bottom-up (model -> repository -> service -> handler -> router).

#### Model Review

- [ ] Structs have proper `json` tags (snake_case, `omitempty` for optional fields)
- [ ] Structs have proper `db` tags matching PostgreSQL column names
- [ ] Types match PostgreSQL column types (e.g., `uuid.UUID` for UUID, `time.Time` for TIMESTAMPTZ)
- [ ] Pointer types used for nullable fields (`*string`, `*time.Time`)
- [ ] Request structs have `validate` tags for input validation
- [ ] Response structs exclude sensitive fields (password_hash, internal IDs not needed by frontend)
- [ ] Doc comments on all exported types

#### Repository Review

- [ ] **SQL injection prevention:** All user input passed via parameterized queries (`$1`, `$2`), NEVER via string concatenation or `fmt.Sprintf`
- [ ] `context.Context` is the first parameter on every method
- [ ] `pgx.ErrNoRows` mapped to `model.ErrNotFound`
- [ ] All errors wrapped with method context: `fmt.Errorf("repo.MethodName: %w", err)`
- [ ] `Scan()` column order matches `SELECT` column order exactly
- [ ] No business logic (no `if isAdmin` checks, no validation, no HTTP concepts)
- [ ] `LIMIT` and `OFFSET` used for paginated queries (no unbounded `SELECT *`)
- [ ] Proper use of transactions where multiple writes must be atomic
- [ ] Doc comments on all exported methods

#### Service Review

- [ ] No `net/http` imports (service must be HTTP-agnostic)
- [ ] Business rules enforced (ownership, permissions, uniqueness, limits)
- [ ] All errors wrapped with service context
- [ ] Edge cases handled (empty input, zero values, nil pointers)
- [ ] No direct database access (all queries go through repository)
- [ ] Input validation for rules that require DB state (e.g., uniqueness checks)
- [ ] Doc comments on all exported methods

#### Handler Review

- [ ] **Proper HTTP status codes:**
  - `200 OK` for successful GET, PUT
  - `201 Created` for successful POST that creates a resource
  - `204 No Content` for successful DELETE
  - `400 Bad Request` for validation errors
  - `401 Unauthorized` for missing/invalid auth
  - `403 Forbidden` for insufficient permissions
  - `404 Not Found` for missing resources
  - `409 Conflict` for duplicate resources
  - `500 Internal Server Error` for unexpected errors
- [ ] **Input validation:** Request body decoded and validated before service call
- [ ] **Path parameters:** Extracted with `chi.URLParam()` and validated (UUID parse check)
- [ ] **No business logic:** Handler only parses request, calls service, writes response
- [ ] **Error responses:** Use centralized error response helper, not ad-hoc `json.NewEncoder`
- [ ] **Request body closed:** `json.NewDecoder(r.Body)` used (auto-closes), no manual `ioutil.ReadAll`
- [ ] **Response content type:** `Content-Type: application/json` set on all JSON responses
- [ ] Doc comments stating the endpoint (`// Create handles POST /api/v1/resources.`)

#### Router Review

- [ ] Routes registered under correct path prefix (`/api/v1/{resource}`)
- [ ] Auth middleware applied to protected routes (not applied to public routes like health, login)
- [ ] HTTP methods match handler names (GET -> List/GetByID, POST -> Create, PUT -> Update, DELETE -> Delete)
- [ ] No duplicate route registrations
- [ ] Middleware chain order is correct (RequestID -> RealIP -> Logger -> Recovery -> CORS -> Timeout -> Auth)

#### Migration Review

- [ ] Up migration is idempotent-safe or uses `IF NOT EXISTS`
- [ ] Down migration reverses the up migration completely
- [ ] Sequence number does not conflict with existing migrations
- [ ] Foreign keys reference existing tables
- [ ] Indexes created on foreign key columns and frequently queried columns
- [ ] Column types appropriate (`VARCHAR` with length limits, `TEXT` for unbounded, `TIMESTAMPTZ` not `TIMESTAMP`)
- [ ] `NOT NULL` constraints on required fields
- [ ] Default values set where appropriate (`DEFAULT NOW()`, `DEFAULT gen_random_uuid()`)

### 3. Cross-Cutting Concerns

- [ ] **Error handling:** Errors wrapped at every layer with context. No swallowed errors (bare `_` assignments on error returns).
- [ ] **Logging:** `slog` used for structured logging. No `fmt.Println` or `log.Printf`.
- [ ] **Context propagation:** `context.Context` passed through all layers, never `context.Background()` in handler/service/repo.
- [ ] **Resource cleanup:** Database connections, file handles, HTTP response bodies properly closed.
- [ ] **Concurrency safety:** No shared mutable state without synchronization. If goroutines are used, proper error handling and context cancellation.
- [ ] **Secrets:** No hardcoded credentials, tokens, or connection strings. All sensitive values from environment variables.
- [ ] **Dependencies:** New dependencies justified. Prefer stdlib where possible.

### 4. Categorize Findings

Group issues by severity:

**[CRITICAL] -- Must fix before merge:**
- SQL injection vulnerability (string interpolation in queries)
- Missing authentication on protected endpoint
- Panic-causing nil pointer dereference
- Data loss risk (wrong DELETE query, missing WHERE clause)
- Compilation errors
- Secrets hardcoded in source

**[WARN] -- Should fix, non-blocking:**
- Missing error wrapping (errors returned unwrapped)
- Missing input validation on a field
- Wrong HTTP status code (200 instead of 201)
- Missing database index on frequently queried column
- Unbounded query without LIMIT
- Missing doc comment on exported function

**[INFO] -- Suggestion, optional:**
- Naming improvement
- Code organization suggestion
- Performance optimization opportunity
- Potential future refactor
- Alternative stdlib approach available

### 5. Report Results

Produce output following FORMAT.md:

1. **Summary:** "Reviewed {N} files across {layers}. Found {X} critical, {Y} warning, {Z} info issues."
2. **Files Created/Modified:** "No files modified (review only)."
3. **Code Summary:** List of files reviewed with brief assessment per file.
4. **Build Verification:** Run `go build ./...` and `go vet ./...` to confirm code compiles.
5. **Dependencies Added:** "N/A (review only)."
6. **Issues & Recommendations:** Full categorized list of findings with file paths and line references.
7. **Quality Checklist.**

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] All files in scope reviewed
- [ ] Every layer checked against its specific checklist
- [ ] SQL injection prevention verified for all queries
- [ ] HTTP status codes verified for all handlers
- [ ] Error handling verified at every layer
- [ ] Issues categorized by severity ([CRITICAL], [WARN], [INFO])
- [ ] Actionable recommendations provided with file paths
- [ ] `go build ./...` passes
- [ ] `go vet ./...` passes
- [ ] Output matches FORMAT.md
