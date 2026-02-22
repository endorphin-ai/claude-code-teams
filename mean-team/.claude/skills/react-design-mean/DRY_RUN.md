# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze
- Read the PRD to extract all user-facing features and their acceptance criteria
- Map each feature to pages and key components
- Identify shared UI patterns across features (forms, lists, cards, modals)
- Check for existing React components, pages, and routing in the codebase
- Read the API design docs to understand available endpoints for data fetching

## What to Output

### 1. Page Inventory

```markdown
| Page | Route | PRD Feature | Auth | Complexity |
|------|-------|-------------|------|------------|
| Login | /login | F1, F2 | Public | Low |
| Dashboard | /dashboard | F3 | Protected | Medium |
| Post Editor | /posts/new | F4 | Protected | High |
```

### 2. Component Estimate
- Total pages: X
- Estimated components: Y (page-level) + Z (reusable)
- Layout types: list (e.g., MarketingLayout, AppLayout, AuthLayout)

### 3. State Management Recommendation
- Auth state: Context (simple) or Redux (complex role-based)
- Server state: React Query (recommended) or useEffect + useState
- Form state: controlled components or form library (Formik, React Hook Form)
- Rationale for each choice

### 4. Layout Strategy
- Number of distinct layouts needed
- Responsive approach (CSS Grid, Flexbox, framework)
- Navigation pattern (top nav, sidebar, or both)

### 5. Complexity Flags
1. [ARCH] Feature F6 requires real-time updates — consider WebSocket integration in component design
2. [UX] Feature F3 has complex filtering — may need dedicated FilterBar component
3. [WARN] No design mockups provided — component structure based on PRD text only

## What NOT to Do
- DO NOT write component trees or full hierarchical diagrams
- DO NOT create any files on disk
- DO NOT write JSX, CSS, or component code
- DO NOT install packages or modify package.json
- DO still read the PRD, API docs, and existing codebase to make real design decisions
