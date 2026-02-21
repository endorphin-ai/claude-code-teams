# Workflow: Code Review (Phase 4 -- Review)

Use this playbook when reviewing implemented code against the system design document. This is the Phase 4 workflow: compare what was built to what was designed, flag deviations, detect anti-patterns, and produce a verdict.

## Prerequisites

- System design document exists (produced in Phase 1)
- Implementation is complete (produced in Phase 2 backend + Phase 3 frontend, or equivalent)
- All Go files, migration files, and React component files are accessible in the codebase

## Steps

### 1. Read the Design Document

Parse the design doc and extract all checkable artifacts:

- **API Endpoints:** method, path, request type, response type, status codes for each
- **DB Tables:** table name, columns, types, indexes, constraints, relationships for each
- **React Components:** component name, type (page/container/presentational), props for each
- **Go Structure:** expected files in handler/, service/, repository/, model/, dto/

Build a checklist of every discrete artifact that should exist in the implementation.

### 2. Scan All Implementation Files

Read every relevant file in the codebase:

**Go Backend:**
- `cmd/server/main.go` -- DI wiring, startup
- `internal/router/router.go` -- Route definitions (extract actual endpoints)
- `internal/handler/*.go` -- All handler files
- `internal/service/*.go` -- All service files
- `internal/repository/*.go` -- All repository files
- `internal/model/*.go` -- All model files
- `internal/dto/*.go` -- All DTO files
- `internal/handler/middleware.go` -- Middleware definitions

**Database:**
- `migrations/*.up.sql` -- All UP migrations (extract actual tables, columns, indexes)
- `migrations/*.down.sql` -- Verify DOWN migrations exist

**React Frontend:**
- `src/pages/*.tsx` -- All page components
- `src/components/*.tsx` -- All shared components
- `src/containers/*.tsx` -- All container components (if used)
- `src/hooks/*.ts` -- Custom hooks
- `src/types/*.ts` -- Type definitions
- `src/api/*.ts` -- API client files

Do NOT skim. Read each file fully. Record the actual implementation facts.

### 3. Check API Conformance

For each endpoint in the design document:

1. **Exists?** -- Does `router.go` define this route with the correct method and path?
2. **Handler exists?** -- Is there a handler function mapped to this route?
3. **Request type matches?** -- Do the DTO fields match the design (name, type, validation)?
4. **Response type matches?** -- Do the response DTO fields match the design?
5. **Status codes match?** -- Does the handler return all specified status codes?
6. **Auth applied?** -- Is the correct middleware applied per the design?

Record each check result in the Conformance Matrix (see FORMAT.md).

Flag any endpoints that exist in code but NOT in the design (scope creep).

### 4. Check DB Schema Conformance

For each table in the design document:

1. **Migration exists?** -- Is there an UP migration file that creates this table?
2. **Columns match?** -- Do column names, types, and constraints match the design?
3. **Standard columns present?** -- Does it have id (UUID), created_at, updated_at?
4. **Indexes present?** -- Are all designed indexes created?
5. **FK constraints correct?** -- Do foreign keys reference the right table with correct ON DELETE?
6. **DOWN migration exists?** -- Is the corresponding DOWN migration present and correct?
7. **Trigger applied?** -- Is the update_updated_at trigger applied?

Record in the DB Schema Conformance table (see FORMAT.md).

### 5. Check Component Structure Conformance

For each component in the design document:

1. **File exists?** -- Does the component file exist at the expected path?
2. **Component type correct?** -- Is it a page/container/presentational as designed?
3. **Props match?** -- Does the component accept the designed props (names and types)?
4. **Data fetching correct?** -- Do page components use the expected hooks/queries?
5. **Children correct?** -- Does the component render the expected child components?

Record in the Component Structure Conformance table (see FORMAT.md).

### 6. Check Go Patterns

Verify architectural patterns across the entire Go codebase:

**Layer Separation:**
- Handlers ONLY parse requests, call services, write responses
- Handlers DO NOT import repository packages or database/sql
- Services contain business logic, validation, orchestration
- Services DO NOT import net/http or write HTTP responses
- Repositories contain only SQL queries and result scanning
- Repositories DO NOT contain business logic

**Interface Pattern:**
- Interfaces defined in the consumer package (service defines repo interface)
- Implementations in the provider package (repository implements the interface)
- Constructors return the interface type, not the concrete type

**Error Handling:**
- Domain errors defined in model/errors.go
- Services wrap repository errors with domain context
- Handlers map domain errors to HTTP status codes
- No raw error strings exposed to API clients

**Context Propagation:**
- All I/O functions accept context.Context as first parameter
- Context passed from handler through service to repository

**Other Checks:**
- No hardcoded configuration values (connection strings, secrets, ports)
- Parameterized SQL queries (no string concatenation)
- Proper resource cleanup (defer rows.Close(), defer tx.Rollback())
- Consistent JSON field naming (snake_case via struct tags)

Record in the Go Pattern Conformance table (see FORMAT.md).

### 7. Run Anti-Pattern Detection

Scan for known anti-patterns (refer to SKILL.md Section 6 -- Anti-Pattern Detection table):

- **Fat handler:** Business logic in handler files
- **Anemic service:** Service methods that only call repository without adding logic
- **Direct DB in handler:** sql.DB referenced in handler package
- **God component:** React components exceeding 200 lines
- **Prop drilling:** Props passed through more than 2 component levels
- **Raw SQL strings:** Unparameterized queries
- **Missing error handling:** Unchecked error returns in Go
- **N+1 queries:** Database queries inside loops
- **Hardcoded config:** Literals that should be environment variables
- **Missing indexes:** FK columns without corresponding indexes

For each anti-pattern found, record: file, line number, description, and fix suggestion.

### 8. Produce Review Report

Assemble the full review report following FORMAT.md (Review Mode Output):

1. Write Summary with verdict (PASS / FAIL / CONDITIONAL)
2. Write Conformance Matrix (endpoint-by-endpoint)
3. Write DB Schema Conformance table
4. Write Component Structure Conformance table
5. Write Go Pattern Conformance table
6. Write Issues Found table (all issues, sorted by severity)
7. Write Pattern Violations section (detailed per anti-pattern)
8. Write Overall Assessment (counts, blocking issues, recommendations)
9. Complete Quality Checklist
10. List Files Reviewed with issue counts

The verdict logic:
- **PASS:** Zero CRITICAL, zero HIGH issues. All design artifacts implemented.
- **CONDITIONAL:** Zero CRITICAL, 1-3 HIGH issues. Most design artifacts implemented. List conditions for passing.
- **FAIL:** Any CRITICAL issue, OR 4+ HIGH issues, OR major design artifacts missing.

### 9. Report to El-Capitan

Delegate back via `/invoke-el-capitan` with:
- Review verdict (PASS / FAIL / CONDITIONAL)
- Count of issues by severity
- List of blocking issues (if any)
- Whether implementation is ready for merge or needs rework

## Checklist

- [ ] Design document fully parsed (all endpoints, tables, components extracted)
- [ ] Every Go handler, service, repository file read
- [ ] Every migration file read
- [ ] Every React page and component file read
- [ ] API conformance checked endpoint-by-endpoint
- [ ] DB schema conformance checked table-by-table
- [ ] Component structure checked component-by-component
- [ ] Go architectural patterns verified
- [ ] Anti-pattern scan completed
- [ ] Every issue has file:line reference and severity
- [ ] Every issue has an actionable suggestion
- [ ] Verdict determined with justification
- [ ] Output matches FORMAT.md Review Mode structure exactly
