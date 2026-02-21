# Workflow: Code Review (Self-Review)

Use this playbook to self-review React frontend code before reporting completion. This is the final quality gate before delegating back to el-capitan.

## Steps

### 1. TypeScript Strictness

Scan every file created or modified for type safety:

- [ ] **No `any` types** -- search for `: any`, `as any`, `<any>`. Every instance must be replaced with a proper type or `unknown` with narrowing.
- [ ] **No type assertions without justification** -- `as SomeType` should be rare. If used, add a comment explaining why.
- [ ] **Props interfaces defined** -- every component has a `[ComponentName]Props` interface directly above it.
- [ ] **API types match backend** -- compare every field in `src/types/api.ts` against the PRD/design doc API contracts. Field names must match Go JSON struct tags.
- [ ] **Generics used properly** -- `PaginatedResponse<T>`, `UseQueryResult<T>`, etc. No raw unparameterized generics.
- [ ] **Strict null checks** -- no unguarded access to optional fields. Use optional chaining (`?.`) and nullish coalescing (`??`).
- [ ] **Event handler types** -- use proper React event types (`React.ChangeEvent<HTMLInputElement>`, `React.FormEvent<HTMLFormElement>`, etc.).

### 2. Component Quality

Review each component for correctness and best practices:

- [ ] **Single responsibility** -- each component does one thing. If a component exceeds 150 lines, consider splitting.
- [ ] **Composition over inheritance** -- components compose via children and props, not class inheritance.
- [ ] **No side effects in render** -- API calls, timers, and subscriptions happen in hooks (`useEffect`, `useQuery`), never in the render body.
- [ ] **Keys on list items** -- every `.map()` that renders components uses a stable, unique `key` prop (not array index unless the list is static and never reordered).
- [ ] **Memoization where needed** -- expensive computations use `useMemo`, callback props passed to child components use `useCallback` if the child is memoized with `React.memo`.
- [ ] **No prop drilling beyond 2 levels** -- if a prop passes through more than 2 intermediate components, use Context or composition (render props / children).

### 3. Error Handling

Verify graceful error handling throughout:

- [ ] **Error boundaries** -- every page component is wrapped in an `ErrorBoundary` (or the route-level layout provides one).
- [ ] **API error handling** -- TanStack Query `error` state is handled in every component that uses `useQuery` or `useMutation`. Display a user-friendly error message, not a raw error object.
- [ ] **Form submission errors** -- mutations that fail show an error message to the user. The form does not silently fail.
- [ ] **Network errors** -- the axios interceptor handles 401 (redirect to login). Other error codes (400, 403, 404, 500) are surfaced to the user.
- [ ] **Zod validation errors** -- form fields display per-field validation messages from the zod schema.

### 4. Loading States

Verify all async operations have loading indicators:

- [ ] **Query loading** -- every `useQuery` consumer checks `isLoading` and renders a loading indicator (spinner, skeleton, etc.).
- [ ] **Mutation loading** -- every `useMutation` consumer disables the trigger button and shows a loading state while the mutation is in flight (`isSubmitting` or `isPending`).
- [ ] **Route transitions** -- lazy-loaded pages have a `Suspense` fallback.
- [ ] **No flash of empty content** -- the loading state renders before any data-dependent UI.

### 5. Empty States

Verify empty data is handled gracefully:

- [ ] **Empty lists** -- when an API returns an empty array, display an `EmptyState` component with a helpful message (not a blank page).
- [ ] **Missing data** -- when a detail page loads an entity that does not exist (404), display a "not found" message, not a crash.
- [ ] **Conditional rendering** -- nullable/optional fields use conditional rendering or fallback values, not unguarded property access.

### 6. Accessibility Basics

Check for fundamental accessibility compliance:

- [ ] **Form labels** -- every `<input>`, `<select>`, and `<textarea>` has an associated `<label>` element (via `htmlFor`/`id` pairing).
- [ ] **Image alt text** -- every `<img>` has a meaningful `alt` attribute. Decorative images use `alt=""`.
- [ ] **Semantic HTML** -- use `<nav>`, `<main>`, `<section>`, `<article>`, `<header>`, `<footer>` instead of generic `<div>` where semantically appropriate.
- [ ] **Focusable interactive elements** -- all clickable elements are either `<button>` or `<a>`, not `<div onClick>`. If a div must be interactive, it has `role`, `tabIndex`, and keyboard event handlers.
- [ ] **Color contrast** -- text colors against background colors meet WCAG AA contrast ratio (Tailwind's default palette generally satisfies this, but verify custom colors).
- [ ] **Focus indicators** -- interactive elements have visible focus rings (Tailwind's `focus:ring-*` classes).

### 7. Responsive Design

Verify mobile-first responsive patterns:

- [ ] **Base styles are mobile** -- the default (no breakpoint prefix) styles work on small screens (< 640px).
- [ ] **Breakpoint layering** -- `sm:`, `md:`, `lg:`, `xl:` add layout changes for larger screens.
- [ ] **Grid layouts** -- grids start at `grid-cols-1` and add columns at breakpoints.
- [ ] **Text sizing** -- body text is readable on mobile (minimum `text-sm` / 14px).
- [ ] **Touch targets** -- buttons and interactive elements are at least 44x44px on mobile (Tailwind: `min-h-[44px] min-w-[44px]` or adequate padding).
- [ ] **No horizontal overflow** -- no element causes horizontal scrolling on mobile.

### 8. Performance Basics

Check for obvious performance issues:

- [ ] **Routes are lazy-loaded** -- all page components use `React.lazy` with `Suspense`.
- [ ] **No unnecessary re-renders** -- components that receive object/array/function props from parents use `React.memo` if they re-render expensively.
- [ ] **TanStack Query stale times** -- queries have reasonable `staleTime` values (not refetching on every window focus if the data is unlikely to change).
- [ ] **No large inline objects** -- objects and arrays are not created inline in JSX props (causes re-renders). Move to `useMemo` or module-level constants.
- [ ] **Images optimized** -- images use appropriate dimensions, not full-size originals.

### 9. Code Organization

Verify files are in the correct locations:

- [ ] Types in `src/types/`
- [ ] API functions in `src/api/`
- [ ] Custom hooks in `src/hooks/`
- [ ] Reusable components in `src/components/ui/` or `src/components/[feature]/`
- [ ] Page components in `src/pages/`
- [ ] Route config in `src/routes/`
- [ ] Context providers in `src/context/`
- [ ] Utility functions in `src/utils/`
- [ ] No business logic in components (extracted to hooks)
- [ ] Absolute imports using `@/` alias

### 10. Report

After completing the review, output a review summary:

```markdown
## Self-Review Summary

**Files reviewed:** X
**Issues found:** Y (Z critical, W warnings, V info)

### Critical Issues
(List any critical issues that must be fixed before completion)

### Warnings
(List non-blocking issues that should be addressed)

### Info
(List observations and suggestions)

### Review Checklist Status
- [x/] TypeScript strictness
- [x/] Component quality
- [x/] Error handling
- [x/] Loading states
- [x/] Empty states
- [x/] Accessibility basics
- [x/] Responsive design
- [x/] Performance basics
- [x/] Code organization
```

If critical issues are found, fix them before reporting completion. Do not delegate back to el-capitan with unresolved critical issues.

## Checklist

- [ ] All files reviewed against every section above
- [ ] Critical issues fixed
- [ ] Warnings documented in report
- [ ] `npm run build` passes after any review fixes
- [ ] Output matches FORMAT.md structure
