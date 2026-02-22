# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze
- Scan the codebase to identify all backend files (models, controllers, routes, middleware)
- Scan the codebase to identify all frontend files (pages, components, hooks, context)
- Locate architecture documents (PRD, database schema, API design, React design)
- Determine the review scope: full review or targeted review
- Check for test files and CI configuration

## What to Output

### 1. Review Scope

```markdown
| Area | Files Found | Architecture Doc |
|------|------------|-----------------|
| Backend Models | 4 files in server/models/ | database-schema.md found |
| Backend Controllers | 4 files in server/controllers/ | api-design.md found |
| Backend Routes | 4 files in server/routes/ | api-design.md found |
| Backend Middleware | 2 files in server/middleware/ | — |
| Frontend Pages | 6 files in client/src/pages/ | react-design.md found |
| Frontend Components | 12 files in client/src/components/ | react-design.md found |
```

### 2. Dimensions to Check
- Security: auth, input validation, token handling, CORS
- Error Handling: centralized handler, error boundaries, async error catching
- Code Quality: patterns, naming, separation of concerns, DRY
- API Contracts: endpoints match design docs, request/response shapes
- Data Validation: server-side and client-side validation
- Performance: indexes, pagination, lazy loading, bundle size
- Architecture: compliance with PRD, schema, API design, React design

### 3. Architecture Docs Available

```markdown
| Document | Path | Status |
|----------|------|--------|
| PRD | docs/PRD.md | Found |
| Database Schema | docs/database-schema.md | Found |
| API Design | docs/api-design.md | Found |
| React Design | docs/react-design.md | Not found |
```

### 4. Estimated Issues
Based on codebase scan:
- Estimated critical issues: X (based on common patterns found)
- Estimated warnings: Y
- Areas of highest risk: list top 3

## What NOT to Do
- DO NOT perform the actual code review (do not read file contents in detail)
- DO NOT create any files on disk
- DO NOT produce verdicts, issue tables, or the JSON block
- DO NOT modify any code
- DO still scan the file tree and locate architecture docs to plan the review scope
