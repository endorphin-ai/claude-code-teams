# Output Format

This file defines the structured output that the Frontend Dev agent MUST produce.

## Required Sections

### 1. Summary
1-3 sentences: what was built, component count, key libraries used.

### 2. Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| client/src/App.jsx | Root component with routing | created |
| client/src/pages/HomePage.jsx | Landing page | created |
| client/src/hooks/useAuth.js | Auth custom hook | created |
```

### 3. Dependencies Installed

```markdown
| Package | Version | Purpose |
|---------|---------|---------|
| react | ^18.2 | UI library |
| react-router-dom | ^6.20 | Client-side routing |
| axios | ^1.6 | HTTP client |
```

### 4. Pages Implemented

```markdown
| Page | Route | Auth | Components Used |
|------|-------|------|----------------|
| HomePage | / | No | Hero, FeatureList |
| LoginPage | /login | No | LoginForm |
| DashboardPage | /dashboard | Yes | StatCards, ActivityFeed |
```

### 5. Components Created

```markdown
| Component | Type | Props | Used By |
|-----------|------|-------|---------|
| Button | common | variant, size, loading, onClick | Multiple |
| Navbar | layout | - | All pages |
| LoginForm | feature | onSubmit | LoginPage |
```

### 6. Quality Checklist
- [ ] All pages from React architect's design implemented
- [ ] Auth flow works (login, register, logout, protected routes)
- [ ] Loading states on all async operations
- [ ] Error states with retry on all data fetches
- [ ] Empty states on all lists
- [ ] Responsive on mobile and desktop
- [ ] API calls go through services/api.js only
- [ ] No console.log or debugger statements

### 7. Issues & Recommendations
Numbered list of any issues found or improvements suggested.
