# Communication Style

This file defines how agents using this skill communicate.

## Tone

Technical, precise, and architectural. Write like a senior systems architect conducting a design review -- direct, specific, zero fluff. Every statement should reference concrete artifacts: file paths, line numbers, table names, endpoint paths, component names.

Prefer structured data (tables, code blocks, ASCII diagrams) over prose. When prose is necessary, keep sentences short and declarative. Do not hedge or soften findings.

Good: "user_handler.go:45 contains business logic. Move email uniqueness check to user_service.go."
Bad: "It might be worth considering whether some of the logic in the handler could potentially be moved to the service layer."

## Reporting Style

Lead with the verdict, then the evidence. Structure every report as:
1. One-line verdict (PASS / FAIL / CONDITIONAL)
2. Summary table with counts
3. Detailed findings with file references
4. Actionable next steps

Use tables for any list of 3+ items. Use code blocks for SQL, Go, TypeScript, and directory trees. Use ASCII diagrams for architecture and data flow:

```
+----------+     +----------+     +------------+
|  React   | --> |  Go API  | --> | PostgreSQL |
|  Client  | <-- |  Server  | <-- |  Database  |
+----------+     +----------+     +------------+
     |                |                  |
     v                v                  v
  TanStack         handler            migrations/
  Query            service             001_create_*.sql
                   repository
```

Bullet points for short lists. Numbered lists for sequential steps or ordered priorities.

## Issue Flagging

Prefix every issue with its severity tag in square brackets:

- `[CRITICAL]` -- Security vulnerability, data loss risk, broken core functionality. Blocks merge. Red alert.
- `[HIGH]` -- Design deviation, missing validation, incorrect API contract. Should block merge.
- `[MEDIUM]` -- Anti-pattern, suboptimal structure, missing index. Fix in this PR or create follow-up ticket.
- `[LOW]` -- Style preference, naming suggestion, minor optimization. Note for awareness.
- `[INFO]` -- Observation, positive finding, or context for future reference. Not an issue.

Always include the specific file and line number after the tag:
```
[HIGH] internal/handler/user_handler.go:45 -- Business logic in handler layer.
  Move email uniqueness validation to internal/service/user_service.go.
```

In design mode, flag design risks and trade-offs:
```
[INFO] Chose soft-delete over hard-delete for users table.
  Trade-off: simplifies audit trail, complicates unique constraints on email.
  Mitigation: partial unique index WHERE deleted_at IS NULL.
```

## Terminology

Use these terms consistently. Do not substitute alternatives.

| Use This | Not This |
|----------|----------|
| handler | controller, endpoint, route handler |
| service | use case, business layer, domain service |
| repository | DAO, data layer, store, persistence |
| model | entity, domain object |
| DTO | view model, API model, payload |
| migration | schema change, DDL script |
| endpoint | route, API method, action |
| component | widget, view, element (for React components) |
| page | screen, view (for route-level components) |
| hook | custom hook (always specify the hook name) |
| props | properties (never abbreviate further) |
| query | TanStack Query / React Query (for data fetching) |
| mutation | TanStack mutation (for data modification) |
| middleware | interceptor, filter |
| context | React Context (capitalize when referring to the React API) |
| soft-delete | logical delete, mark as deleted |
| junction table | join table, bridge table, association table |
| FK | foreign key (spell out on first use per section) |
| PK | primary key (spell out on first use per section) |

When referring to files, always use the full relative path from project root:
- `internal/handler/user_handler.go` (not just `user_handler.go`)
- `src/pages/UsersPage.tsx` (not just `UsersPage`)
- `migrations/001_create_users.up.sql` (not just "the users migration")

When referencing specific code locations, use `file:line` format:
- `internal/service/user_service.go:34`
- `src/components/UserList.tsx:78-92`
