# Workflow: Implement Frontend for New Feature

Use this playbook when implementing the React frontend from architect designs.

## Steps

1. **Read Architecture Docs** -- Load React design and API contracts from previous phases. Extract: pages, components, routing, state management plan, API endpoints.

2. **Setup Project** -- Create client directory with Vite + React. Install dependencies. Set up folder structure per architecture design.

3. **Implement Services** -- Create API client with Axios instance, interceptors for auth token, error handling.

4. **Implement Hooks** -- Create custom hooks: useAuth, useFetch, useForm, and any feature-specific hooks.

5. **Implement Context** -- Create context providers: AuthContext (user state, login/logout), ThemeContext if needed.

6. **Implement Common Components** -- Build reusable atoms and molecules: Button, Input, Modal, Spinner, Alert, ErrorMessage.

7. **Implement Layout Components** -- Build layout wrappers: Navbar, Sidebar, Footer, PageWrapper, ProtectedRoute.

8. **Implement Feature Components** -- Build feature-specific organisms per architecture design.

9. **Implement Pages** -- Build page components composing feature components, connecting to API via hooks.

10. **Implement Routing** -- Set up React Router with layouts, protected routes, 404 handling.

11. **Wire App** -- Connect App.jsx with AuthProvider, Router, and global styles.

12. **Verify** -- Check all pages render, auth flow works, API integration correct.

13. **Format Output** -- Structure per FORMAT.md.

## Checklist
- [ ] All pages from architecture design implemented
- [ ] Auth flow: login, register, logout, token refresh, protected routes
- [ ] Loading states on every async operation
- [ ] Error states with retry on every data fetch
- [ ] Empty states on every list
- [ ] Forms with validation and error display
- [ ] Responsive layout
- [ ] Output matches FORMAT.md
