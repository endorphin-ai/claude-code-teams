# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze

Perform all real analysis. Read the PRD, scan the existing codebase, and make genuine architectural decisions. The only difference from a live run is that no files are created or modified.

### Design Mode (Phase 1) Dry-Run

1. **Read the PRD** -- Extract every requirement, user story, and acceptance criterion.
2. **Identify entities** -- List all domain entities implied by the PRD (users, projects, tasks, etc.).
3. **Sketch API endpoints** -- List each endpoint with method, path, and purpose. Do NOT produce full request/response type definitions.
4. **Sketch DB tables** -- List each table with column names and types. Do NOT produce full CREATE TABLE statements.
5. **Sketch component tree** -- List top-level page components and their data needs. Do NOT produce full prop definitions.
6. **Identify Go packages** -- List the handler/service/repository files that would be created. Do NOT produce the full directory tree with annotations.
7. **Identify risks and open questions** -- Flag ambiguities in the PRD, potential scaling issues, unclear requirements, or design trade-offs that need human input.

### Review Mode (Phase 4) Dry-Run

1. **Read the design doc** -- Parse all endpoints, tables, and components from the design.
2. **Scan codebase** -- Identify which Go files, migration files, and React components exist.
3. **Produce coverage summary** -- How many design artifacts have corresponding implementations? Express as fractions (e.g., "8/10 endpoints implemented").
4. **Spot-check patterns** -- Pick 2-3 files and check for layer violations or anti-patterns. Do NOT perform an exhaustive file-by-file review.
5. **Flag obvious gaps** -- List any design artifacts with zero implementation.
6. **Estimate full review scope** -- How many files would a full review cover? Estimated time?

## What to Output

### Design Dry-Run Report

```markdown
## Dry-Run: System Design

### Entities Identified
- User (core, auth)
- Project (user-owned)
- Task (project-scoped)

### API Endpoints (sketch)
| Method | Path | Purpose |
|--------|------|---------|
| POST | /api/v1/auth/login | Authenticate user |
| GET | /api/v1/users | List users |
| ... | ... | ... |

Total: {N} endpoints across {M} resources

### DB Tables (sketch)
| Table | Key Columns | Relationships |
|-------|-------------|---------------|
| users | email, name, password_hash | has_many: projects |
| projects | name, description, user_id | belongs_to: users, has_many: tasks |
| ... | ... | ... |

Total: {N} tables, {M} junction tables

### Component Tree (sketch)
- UsersPage -> UserList, UserFilters
- ProjectsPage -> ProjectList, ProjectCard
- ...

Total: {N} page components, {M} shared components

### Go Packages
- handler: {N} handler files
- service: {N} service files
- repository: {N} repository files
- migrations: {N} migration pairs

### Architecture Decisions
1. {Decision}: {Rationale}
2. {Decision}: {Rationale}

### Risks & Open Questions
1. [RISK] {Description} -- {Impact if not addressed}
2. [QUESTION] {Ambiguity in PRD} -- {What needs clarification}

### Estimated Scope
- Design document: ~{N} sections
- Migration files: {N} pairs
- Estimated complexity: LOW | MEDIUM | HIGH
```

### Review Dry-Run Report

```markdown
## Dry-Run: Code Review

### Coverage Summary
- Endpoints: {implemented}/{total} from design
- DB tables: {migrated}/{total} from design
- Components: {created}/{total} from design

### Spot-Check Findings
- {file:line} -- {finding}
- {file:line} -- {finding}

### Obvious Gaps
- {Missing endpoint/table/component}

### Full Review Estimate
- Files to review: {N} Go files, {M} React files, {K} migrations
- Estimated issues: {range based on spot-check extrapolation}
```

## What NOT to Do

- DO NOT create, modify, or delete any files
- DO NOT produce full CREATE TABLE SQL statements (use sketches)
- DO NOT produce full request/response type definitions (use lists)
- DO NOT produce full component prop interfaces (use summaries)
- DO NOT write the design document or review report to disk
- DO NOT install packages or run build commands
- DO NOT modify configuration files
- DO still read skills, scan codebase, read the PRD, and make real architectural decisions
- DO still flag risks, ambiguities, and potential issues
