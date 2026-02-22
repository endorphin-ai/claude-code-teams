# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Summary
1-3 sentences: number of pages, component architecture approach, state management choice, and alignment with PRD features.

### 2. Pages Overview

```markdown
| Page | Route | Auth | Layout | PRD Feature |
|------|-------|------|--------|-------------|
| Landing | / | Public | MarketingLayout | — |
| Login | /login | Public | AuthLayout | F1, F2 |
| Register | /register | Public | AuthLayout | F1 |
| Dashboard | /dashboard | Protected | AppLayout | F3 |
| Post Detail | /posts/:id | Protected | AppLayout | F4 |
```

### 3. Component Tree
Hierarchical diagram showing component nesting:

```
App
├── BrowserRouter
│   ├── MarketingLayout
│   │   └── LandingPage
│   ├── AuthLayout
│   │   ├── LoginPage
│   │   │   └── LoginForm
│   │   └── RegisterPage
│   │       └── RegisterForm
│   └── AppLayout
│       ├── Navbar
│       │   ├── Logo
│       │   ├── NavLinks
│       │   └── UserMenu
│       ├── Sidebar (optional)
│       ├── DashboardPage
│       │   ├── StatsCards
│       │   └── RecentActivity
│       └── PostDetailPage
│           ├── PostContent
│           └── CommentSection
│               ├── CommentList
│               └── CommentForm
```

### 4. Routing Plan
React Router configuration with auth guards:

```jsx
<Routes>
  <Route element={<MarketingLayout />}>
    <Route path="/" element={<LandingPage />} />
  </Route>
  <Route element={<AuthLayout />}>
    <Route path="/login" element={<LoginPage />} />
    <Route path="/register" element={<RegisterPage />} />
  </Route>
  <Route element={<ProtectedRoute />}>
    <Route element={<AppLayout />}>
      <Route path="/dashboard" element={<DashboardPage />} />
      <Route path="/posts/:id" element={<PostDetailPage />} />
    </Route>
  </Route>
</Routes>
```

### 5. State Management Plan

```markdown
| State Domain | Storage | Scope | Key Data |
|-------------|---------|-------|----------|
| Auth | Context + localStorage | Global | user, token, isAuthenticated |
| Posts | React Query / useEffect | Page-level | posts[], loading, error |
| UI | Local state | Component | modals, dropdowns, form inputs |
| Theme | Context | Global | darkMode, colorScheme |
```

### 6. Reusable Components Inventory

```markdown
| Component | Purpose | Props | Used By |
|-----------|---------|-------|---------|
| Button | Primary action button | variant, size, onClick, disabled | All forms |
| Input | Form text input | label, type, error, value, onChange | All forms |
| Modal | Overlay dialog | isOpen, onClose, title, children | Delete confirm, create forms |
| Card | Content container | title, children, actions | Dashboard, lists |
| LoadingSpinner | Async loading state | size | All pages with data fetching |
| ProtectedRoute | Auth guard wrapper | — | All authenticated routes |
```

### 7. Design Decisions
Numbered list explaining key UI/UX architecture choices:

```markdown
1. **Three layout types** — MarketingLayout (public pages, no nav), AuthLayout (centered forms), AppLayout (nav + sidebar + content) to match different user contexts.
2. **Auth via Context** — Simple JWT auth doesn't need Redux. Context + useReducer handles login/logout/token refresh.
3. **React Query for server state** — Separates server state (posts, comments) from UI state. Automatic caching, refetching, and loading states.
```

### 8. Quality Checklist

- [ ] Every PRD feature has at least one page or component
- [ ] All routes defined with correct auth guards
- [ ] Component tree shows clear parent-child relationships
- [ ] Reusable components identified and listed
- [ ] State management strategy covers all data domains
- [ ] Layout components handle responsive design
- [ ] Error and loading states planned for all async operations
- [ ] Navigation flow matches PRD user stories

## Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| client/src/App.jsx | Root component with routing | created |
| client/src/layouts/AppLayout.jsx | Authenticated page layout | created |
| client/src/pages/DashboardPage.jsx | Dashboard page | created |
| client/src/components/Navbar.jsx | Navigation bar | created |
```

## Issues & Recommendations
Numbered list with severity flags. See VOICE.md for flag definitions.
