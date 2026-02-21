# Workflow: New Feature Implementation

Use this playbook when implementing a new React feature from a PRD and design doc.

## Prerequisites

Before starting, confirm you have:
- PRD with acceptance criteria
- Design doc with component tree and API contracts
- Backend API endpoints either implemented or contracts defined

## Steps

### 1. Read PRD + Design Doc

- Extract the feature requirements and acceptance criteria from the PRD
- Extract the component tree from the design doc -- identify every component, its parent, and its props
- Extract all API contracts -- endpoints, HTTP methods, request/response shapes
- Identify which routes/pages are needed
- Note any form requirements (fields, validation rules)

### 2. Define TypeScript Types from API Contracts

Create or update `src/types/api.ts` with types that mirror the Go backend structs exactly.

- Every API response field maps to a TypeScript property
- Use Go JSON struct tag names as property names (typically snake_case)
- Use string union types for enums (e.g., `"admin" | "user"`)
- Use `string` for Go `time.Time` fields (ISO 8601 format)
- Create separate `Create[Resource]Request` and `Update[Resource]Request` interfaces
- Create `PaginatedResponse<T>` if pagination is used

Verify types match the backend contracts in the PRD. If there is a mismatch, flag it as `[API CONTRACT MISMATCH]` in the report.

### 3. Create API Client Functions

Create `src/api/[resource].ts` with typed functions for each endpoint.

- Import `apiClient` from `./client`
- Import types from `@/types/api`
- One exported async function per endpoint
- Each function has typed parameters and return type
- Use `apiClient.get/post/put/delete` -- destructure `{ data }` from response
- Follow naming convention: `get[Resources]`, `get[Resource]ById`, `create[Resource]`, `update[Resource]`, `delete[Resource]`

### 4. Build Reusable UI Components (Bottom-Up)

Starting from the leaf nodes of the design doc component tree, build upward:

- Create each component in `src/components/[feature]/` or `src/components/ui/` (if reusable across features)
- Define `[ComponentName]Props` interface above each component
- Use named exports (not default)
- Apply Tailwind classes for styling (mobile-first)
- Handle all visual states: default, hover, focus, disabled, loading
- Use `clsx` for conditional class composition
- Keep components pure -- extract logic into hooks

### 5. Build Page Components

Create page components in `src/pages/`:

- Each page composes the reusable components from step 4
- Use default export (required for `React.lazy`)
- Wire up TanStack Query hooks for data fetching (see step 7)
- Handle four states: loading, error, empty, success
- Wrap in `ErrorBoundary`
- Use `useParams` for route parameters, `useSearchParams` for query parameters

### 6. Set Up Routes

Update `src/routes/index.tsx`:

- Import page components with `lazy(() => import("@/pages/[PageName]"))`
- Add routes to the router tree in the appropriate location
- Wrap authenticated routes in `<ProtectedRoute>`
- Wrap lazy components in `<LazyPage>` (Suspense wrapper)

### 7. Add State Management

**Server state (TanStack Query):**
- Create hooks in `src/hooks/use[Resource].ts`
- `useQuery` for read operations with appropriate query keys
- `useMutation` for write operations with `onSuccess` cache invalidation
- Use `queryClient.invalidateQueries` to keep data fresh after mutations

**Global client state (React Context):**
- Only if the feature needs cross-component state that is NOT server data
- Create `src/context/[Name]Context.tsx` with `useReducer` for complex state
- Provide the context in `App.tsx` or the appropriate layout component

**Form state (React Hook Form):**
- See step 8

### 8. Add Form Validation (If Needed)

If the feature includes forms:

- Define zod schema in the component file or `src/utils/validation.ts` (if shared)
- Derive the form data type with `z.infer<typeof schema>`
- Use `useForm<FormData>({ resolver: zodResolver(schema) })`
- Wire up `register` to input elements
- Display `errors.[field].message` below each input
- Handle `isSubmitting` state for the submit button
- Call the appropriate `useMutation` hook on form submit

### 9. Run Build and Fix TypeScript Errors

```bash
npm run build
```

- Fix all TypeScript errors -- zero errors is the goal
- Common issues: missing type imports, incorrect prop types, unhandled nullable fields
- If there are warnings, document them in the report but do not block on them

### 10. Report Files Created

Output results in FORMAT.md structure. Include:
- Summary of what was implemented
- Files created/modified table
- Components created with props interfaces
- API client functions with endpoints and types
- TanStack Query hooks with query keys
- Build verification result
- Quality checklist
- Issues and recommendations

Then delegate back to el-capitan.

## Checklist

- [ ] All acceptance criteria from PRD are addressed
- [ ] TypeScript types mirror backend API contracts exactly
- [ ] All API client functions are typed with request/response types
- [ ] Components follow skill patterns (functional, typed props, Tailwind)
- [ ] Page components handle loading, error, empty, and success states
- [ ] Routes are lazy-loaded with Suspense fallback
- [ ] Forms use React Hook Form + zod validation
- [ ] Mobile-first responsive design applied
- [ ] Accessibility basics: labels, alt text, semantic HTML, focusable elements
- [ ] Error boundaries wrap page-level components
- [ ] No `any` types in the codebase
- [ ] No inline styles (Tailwind only)
- [ ] `npm run build` passes with zero TypeScript errors
- [ ] Output matches FORMAT.md structure
- [ ] No files modified outside the feature scope
