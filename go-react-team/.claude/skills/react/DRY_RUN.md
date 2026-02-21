# Dry-Run Behavior

When `--dry-run` is active, the react-dev agent executes the FULL analysis pipeline but produces plans instead of writing files.

## What to Analyze

Perform all of the following real analysis steps:

1. **Read the PRD and design doc** -- Extract the component tree, API contracts, page routes, and acceptance criteria. Identify every component that needs to exist.
2. **Scan existing codebase** -- Read `src/types/`, `src/api/`, `src/components/`, `src/pages/`, `src/hooks/`, `src/routes/`, `src/context/` to understand what already exists.
3. **Map API contracts** -- For each backend endpoint in the PRD, define the TypeScript request/response types that would be created. Verify alignment with Go struct definitions if available.
4. **Plan component hierarchy** -- From the design doc component tree, determine which components are primitives (ui/), which are feature-specific, and which are page-level. Identify composition relationships.
5. **Identify dependencies** -- List npm packages needed (if any new ones beyond the standard stack). Check if TanStack Query, React Hook Form, zod, axios, clsx are already in package.json.
6. **Detect conflicts** -- Check if any planned files would overwrite existing files. Check if planned types conflict with existing type definitions.

## What to Output

The dry-run report must contain all of the following sections:

### Component Plan

List every component that WOULD be created, in bottom-up order:

```markdown
| Component | File Path | Props Interface | Parent Component | Route |
|-----------|-----------|----------------|-----------------|-------|
| UserAvatar | src/components/ui/UserAvatar.tsx | `{ src: string; size?: "sm" \| "md" \| "lg"; alt: string }` | UserCard | -- |
| UserCard | src/components/users/UserCard.tsx | `{ user: User; onSelect?: (id: string) => void }` | UserList | -- |
| UserList | src/components/users/UserList.tsx | `{ users: User[]; onSelect?: (id: string) => void }` | UsersPage | -- |
| UserForm | src/components/users/UserForm.tsx | `{ onSubmit: (data: CreateUserFormData) => void }` | UsersPage | -- |
| UsersPage | src/pages/UsersPage.tsx | -- | AppLayout (route) | /users |
| UserDetailPage | src/pages/UserDetailPage.tsx | -- | AppLayout (route) | /users/:id |
```

### TypeScript Types Plan

List every type/interface that WOULD be created or modified:

```markdown
| Type | File | Fields | Mirrors Backend |
|------|------|--------|----------------|
| User | src/types/api.ts | id, email, name, role, created_at, updated_at | Go User struct |
| CreateUserRequest | src/types/api.ts | email, name, password, role? | Go CreateUserRequest |
```

### API Client Functions Plan

```markdown
| Function | File | Endpoint | Request Type | Response Type |
|----------|------|----------|-------------|---------------|
| getUsers | src/api/users.ts | GET /users | query params | PaginatedResponse<User> |
| createUser | src/api/users.ts | POST /users | CreateUserRequest | User |
```

### TanStack Query Hooks Plan

```markdown
| Hook | File | Query Key | Invalidates |
|------|------|-----------|-------------|
| useUsers | src/hooks/useUsers.ts | ["users"] | -- |
| useCreateUser | src/hooks/useUsers.ts | -- | ["users"] |
```

### Route Changes Plan

```markdown
| Route | Page Component | Auth Required | Lazy Loaded |
|-------|---------------|---------------|-------------|
| /users | UsersPage | yes | yes |
| /users/:id | UserDetailPage | yes | yes |
```

### File Plan Summary

```markdown
| Action | File Path | Purpose |
|--------|-----------|---------|
| create | src/types/api.ts | User-related TypeScript types |
| create | src/api/users.ts | User CRUD API functions |
| create | src/hooks/useUsers.ts | TanStack Query hooks for users |
| create | src/components/users/UserCard.tsx | User display card |
| create | src/components/users/UserForm.tsx | User create/edit form |
| create | src/pages/UsersPage.tsx | Users list page |
| create | src/pages/UserDetailPage.tsx | User detail page |
| modify | src/routes/index.tsx | Add user routes |
```

### Dependencies

List any npm packages that need to be installed (beyond the standard stack).

### Risks and Concerns

Flag any issues discovered during analysis:
- API contract mismatches between PRD and existing backend
- Missing backend endpoints
- Conflicting type definitions
- Accessibility concerns in the design doc component tree
- Performance concerns (large lists without virtualization, etc.)

### Scope Estimate

```markdown
Files to create: X
Files to modify: Y
Components: Z
API functions: N
Estimated complexity: low / medium / high
```

## What NOT to Do

- DO NOT create, modify, or delete any files
- DO NOT install packages or run npm commands
- DO NOT run `npm run build` or any build/lint commands
- DO NOT modify `vite.config.ts`, `tsconfig.json`, `tailwind.config.ts`, or `package.json`
- DO still read all skill files, scan the full codebase, and make real architecture decisions
- DO still flag real issues and real risks based on actual codebase analysis
