# Output Format

This file defines the structured output that the react-dev agent MUST produce after completing work.
El-capitan and downstream phases parse this output -- deviations break the pipeline.

## Required Output Sections

### 1. Summary

One to three sentences describing what was implemented. Include the feature name, number of components created, and whether the build passes.

Example: "Implemented the User Management feature. Created 5 components (UserList, UserCard, UserForm, UserDetail, UserSearch), 3 API client functions, and 2 page routes. Build passes with zero TypeScript errors."

### 2. Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| src/types/api.ts | User, CreateUserRequest, UpdateUserRequest types | created |
| src/api/users.ts | getUsers, getUserById, createUser, updateUser, deleteUser | created |
| src/hooks/useUsers.ts | useUsers, useUser, useCreateUser, useUpdateUser hooks | created |
| src/components/users/UserCard.tsx | User display card component | created |
| src/components/users/UserForm.tsx | Create/edit user form with validation | created |
| src/pages/UsersPage.tsx | Users list page with search and pagination | created |
| src/pages/UserDetailPage.tsx | Single user detail page | created |
| src/routes/index.tsx | Added /users and /users/:id routes | modified |
```

### 3. Components Created

For each component, report the name, its props interface, and the route path if it is a page component.

```markdown
| Component | Props Interface | Route |
|-----------|----------------|-------|
| UserCard | `{ user: User; onSelect?: (id: string) => void; variant?: "compact" \| "full" }` | -- |
| UserForm | `{ onSubmit: (data: CreateUserFormData) => void; defaultValues?: Partial<User>; isLoading?: boolean }` | -- |
| UserSearch | `{ onSearch: (query: string) => void; placeholder?: string }` | -- |
| UsersPage | -- (page component, no props) | /users |
| UserDetailPage | -- (page component, no props, uses useParams) | /users/:id |
```

### 4. API Client Functions

For each API function created, report the function name, HTTP method + endpoint, and request/response types.

```markdown
| Function | Endpoint | Request Type | Response Type |
|----------|----------|-------------|---------------|
| getUsers | GET /users | `{ page?: number; limit?: number }` | `PaginatedResponse<User>` |
| getUserById | GET /users/:id | -- | `User` |
| createUser | POST /users | `CreateUserRequest` | `User` |
| updateUser | PUT /users/:id | `UpdateUserRequest` | `User` |
| deleteUser | DELETE /users/:id | -- | `void` |
```

### 5. TanStack Query Hooks

For each custom hook wrapping TanStack Query, report the hook name, query key, and what it wraps.

```markdown
| Hook | Query Key | Wraps |
|------|-----------|-------|
| useUsers | ["users"] | getUsers via useQuery |
| useUser(id) | ["users", id] | getUserById via useQuery |
| useCreateUser | -- | createUser via useMutation, invalidates ["users"] |
| useUpdateUser | -- | updateUser via useMutation, invalidates ["users", id] |
```

### 6. Build Verification

Run `npm run build` and report the result. If there are TypeScript errors, list them.

```markdown
**Build status:** PASS / FAIL

**TypeScript errors:** 0

**Warnings:** (list any non-critical warnings)
```

If build fails, list each error with file path, line number, and error message.

### 7. Quality Checklist

```markdown
- [ ] All components are typed with Props interfaces (no `any`)
- [ ] All API functions have typed request/response parameters
- [ ] TanStack Query hooks handle loading, error, and empty states
- [ ] Forms use React Hook Form + zod validation
- [ ] All routes are lazy-loaded with Suspense fallback
- [ ] Mobile-first responsive design applied
- [ ] Accessibility: labels on form inputs, alt on images, semantic HTML
- [ ] Error boundaries wrap page-level components
- [ ] No inline styles (Tailwind only)
- [ ] `npm run build` passes with zero TypeScript errors
```

### 8. Issues and Recommendations

Report any issues discovered during implementation. Use severity prefixes:

- `[CRITICAL]` -- blocks functionality, must fix before merge
- `[WARN]` -- non-blocking but should be addressed soon
- `[INFO]` -- observation or suggestion for future improvement

Example:
```
[WARN] Backend /users endpoint does not return pagination metadata. Used client-side pagination as workaround.
[INFO] Consider adding a UserAvatar component for consistent avatar rendering across the app.
```

## Output Example

```
## Summary
Implemented User Management UI. Created 5 components, 5 API client functions, 4 TanStack Query hooks, and 2 page routes. Build passes with zero TypeScript errors.

## Files Created/Modified
| File | Purpose | Status |
|------|---------|--------|
| src/types/api.ts | User types matching backend | created |
| src/api/users.ts | CRUD API functions | created |
| src/hooks/useUsers.ts | TanStack Query hooks | created |
| src/components/users/UserCard.tsx | User card component | created |
| src/components/users/UserForm.tsx | User create/edit form | created |
| src/pages/UsersPage.tsx | Users list page | created |
| src/pages/UserDetailPage.tsx | User detail page | created |
| src/routes/index.tsx | Added user routes | modified |

## Components Created
| Component | Props Interface | Route |
|-----------|----------------|-------|
| UserCard | `UserCardProps` | -- |
| UserForm | `UserFormProps` | -- |
| UsersPage | -- | /users |
| UserDetailPage | -- | /users/:id |

## API Client Functions
| Function | Endpoint | Request Type | Response Type |
|----------|----------|-------------|---------------|
| getUsers | GET /users | query params | PaginatedResponse<User> |
| createUser | POST /users | CreateUserRequest | User |

## Build Verification
**Build status:** PASS
**TypeScript errors:** 0

## Quality Checklist
- [x] All components typed
- [x] API functions typed
- [x] Loading/error/empty states handled
- [x] Forms validated with zod
- [x] Routes lazy-loaded
- [x] Responsive design
- [x] Accessibility basics
- [x] Error boundaries
- [x] No inline styles
- [x] Build passes

## Issues and Recommendations
[INFO] Consider adding optimistic updates for createUser mutation for better UX.
```
