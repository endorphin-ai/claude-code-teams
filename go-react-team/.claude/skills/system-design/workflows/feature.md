# Workflow: System Design (Phase 1 -- Feature)

Use this playbook when producing a system design document from a PRD. This is the Phase 1 workflow in the fullstack pipeline: PRD goes in, design document comes out.

## Prerequisites

- PRD document exists and is accessible (produced by PM agent in Phase 0)
- PRD contains: feature description, user stories, acceptance criteria, and any technical constraints

## Steps

### 1. Analyze PRD

Read the PRD end-to-end. Extract and organize:

- **Entities:** Every noun that represents a storable domain object (user, project, task, comment, etc.)
- **Actions:** Every verb that implies an API operation (create, list, update, delete, assign, etc.)
- **Relationships:** How entities relate (user owns projects, project contains tasks, etc.)
- **Constraints:** Business rules, validation requirements, access control rules
- **UI Screens:** Every screen or view mentioned (list page, detail page, form, dashboard, etc.)
- **Non-functional requirements:** Performance, scalability, auth method, pagination needs

Create a mental model of the full system before designing any part.

### 2. Design API Endpoints

For each entity + action combination, define an endpoint:

1. Map CRUD actions to standard REST endpoints (GET, POST, PUT, PATCH, DELETE)
2. Map custom actions to appropriate methods (POST for actions, GET for queries)
3. Group endpoints by resource under `/api/v1/{resource}`
4. Define query parameters for list endpoints (filters, sort, pagination)
5. For each endpoint, define:
   - Request body type (field names, types, validation rules)
   - Response body type (field names, types)
   - All possible status codes with meanings
   - Auth requirements (public, authenticated, role-specific)

Cross-check: every user story in the PRD must be achievable with the defined endpoints.

### 3. Design Database Schema

For each entity, create a table:

1. Define columns from entity attributes + request body fields
2. Add standard columns: `id UUID PK`, `created_at`, `updated_at`, `deleted_at` (if soft-delete needed)
3. Define relationships via foreign keys with explicit ON DELETE clauses
4. Add UNIQUE constraints where business rules require uniqueness
5. Design indexes for:
   - All foreign key columns
   - Columns used in WHERE clauses (filters)
   - Columns used in ORDER BY (sorting)
   - Unique constraint columns
6. Create junction tables for many-to-many relationships
7. Write the `update_updated_at` trigger function (once) and apply to all tables
8. Number migrations sequentially: one migration per table or logical group

Cross-check: every request body field maps to a table column (or derived from one).

### 4. Design Component Tree

For each UI screen in the PRD:

1. Create a Page component (route entry point, owns data fetching)
2. Identify data needs: which API endpoints does this page call?
3. Break the page into Container components (state + logic) and Presentational components (rendering)
4. Define props for each component: what data and callbacks flow down?
5. Identify shared components reused across pages (buttons, cards, modals, tables)
6. Identify custom hooks needed (data fetching, form state, auth)
7. Map state management strategy:
   - Server state -> TanStack Query hooks
   - Local UI state -> useState/useReducer
   - Shared state -> React Context
   - URL state -> React Router search params

Cross-check: every acceptance criterion in the PRD is visible in at least one component.

### 5. Define Go Project Structure

Map the design to the Go project layout:

1. List handler files: one per resource (user_handler.go, project_handler.go, auth_handler.go)
2. List service files: one per resource, matching handlers
3. List repository files: one per resource, matching services
4. List model files: one per entity + errors.go
5. List DTO files: one per resource (request/response types) + validation.go
6. Define router.go: route groups, middleware chains
7. Define middleware: auth, CORS, logging, recovery, rate limiting
8. Define config.go: environment variables needed (DB_URL, PORT, JWT_SECRET, etc.)
9. Define main.go: dependency injection order (config -> DB -> repos -> services -> handlers -> router -> server)

Cross-check: every endpoint has a handler, every handler has a service, every service has a repository.

### 6. Identify Integration Points

Document how the layers connect:

1. Frontend -> Backend: API client configuration, auth flow, error handling
2. Backend -> Database: connection pooling, migration strategy, transaction boundaries
3. Cross-cutting: CORS policy, logging format, error response format
4. External services: if any (email, file storage, third-party APIs)

### 7. Produce Design Document

Assemble the full design document following FORMAT.md (Design Mode Output):

1. Write Summary (2-3 sentences)
2. Write API Endpoints table with full type definitions
3. Write Database Schema with complete CREATE TABLE statements
4. Write Component Tree with props
5. Write Go Project Structure with file purposes
6. Write Integration Points
7. Complete Quality Checklist
8. List Files Created/Modified

Output the document in the exact FORMAT.md structure. Do not omit sections.

### 8. Report to El-Capitan

Delegate back via `/invoke-el-capitan` with:
- What was produced (design document location)
- Key architectural decisions made
- Any risks or open questions from the PRD
- Recommendations for the implementation phase

## Checklist

- [ ] Every PRD requirement traced to at least one endpoint
- [ ] Every endpoint has full request/response type definitions
- [ ] Every entity has a table with id, created_at, updated_at
- [ ] Every FK has an index and ON DELETE clause
- [ ] Every UI screen has a page component with data flow defined
- [ ] Go project follows handler -> service -> repository strictly
- [ ] No circular dependencies in the design
- [ ] Integration points documented (frontend-backend, backend-DB)
- [ ] Output matches FORMAT.md Design Mode structure exactly
- [ ] No files modified outside scope without approval
