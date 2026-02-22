# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Verdict
One line, bold: **PASS** or **FAIL** with critical/warning counts.

```markdown
**Verdict: FAIL** — 2 critical issues, 5 warnings found.
```

### 2. Review Summary

```markdown
| Dimension | Backend | Frontend | Status |
|-----------|---------|----------|--------|
| Security | Auth middleware present | Token stored correctly | PASS |
| Error Handling | Centralized handler | Error boundaries missing | WARN |
| Code Quality | Clean controller pattern | Prop drilling in 3 components | WARN |
| API Contracts | Matches design docs | Request shapes match | PASS |
| Data Validation | Server-side validation present | Client-side validation missing | FAIL |
| Performance | Indexes present | No lazy loading | WARN |
| Architecture | MVC pattern followed | Component structure clean | PASS |
```

### 3. Critical Issues (if verdict is FAIL)

```markdown
| # | Location | Issue | Impact |
|---|----------|-------|--------|
| C1 | server/controllers/userController.js:45 | Password returned in login response | Credential exposure |
| C2 | client/src/pages/AdminPage.jsx | No role check — any authenticated user can access | Privilege escalation |
```

### 4. Warnings

```markdown
| # | Location | Issue | Recommendation |
|---|----------|-------|----------------|
| W1 | server/routes/postRoutes.js | No rate limiting on POST endpoints | Add express-rate-limit |
| W2 | client/src/components/PostList.jsx | useEffect missing dependency | Add fetchPosts to deps array |
| W3 | server/models/Post.js | No index on author field | Add index for query performance |
```

### 5. Backend Issues Detail
Grouped by concern:

**Security:**
- C1: `userController.js:45` — Login response includes `passwordHash` field. Fix: exclude password from response using `.select('-passwordHash')` or destructure before sending.

**Performance:**
- W3: `Post.js` — Missing compound index `{ author: 1, createdAt: -1 }`. Queries filtering by author will do collection scans.

**Code Quality:**
- W5: `postController.js` — Error messages hardcoded as strings. Fix: create constants file for error messages.

### 6. Frontend Issues Detail
Grouped by concern:

**Security:**
- C2: `AdminPage.jsx` — Page renders for any authenticated user. Fix: add role check in ProtectedRoute or create AdminRoute guard.

**UX:**
- W2: `PostList.jsx` — React strict mode double-fires useEffect. Missing cleanup function.

**Architecture:**
- W4: `Dashboard.jsx` — Props drilled 3 levels (Dashboard > StatsSection > StatCard). Fix: use context or composition.

### 7. Architecture Compliance Check

```markdown
| Document | Compliance | Notes |
|----------|-----------|-------|
| PRD (features) | 8/10 features implemented | F9, F10 missing |
| Database Schema | Full compliance | All collections match |
| API Design | 14/15 endpoints match | Missing PATCH /users/profile |
| React Design | Partial compliance | Component tree matches, missing ErrorBoundary |
```

### 8. Recommendations
Prioritized action items:

```markdown
1. **Fix C1 and C2 immediately** — security issues that block release
2. Add missing error boundaries in React app (W-series)
3. Implement rate limiting on auth endpoints
4. Add missing F9, F10 features or document as Won't for this version
```

### 9. JSON Verdict Block
MUST appear at the end of every review. Machine-parseable by el-capitan:

```json
{
  "verdict": "FAIL",
  "critical_count": 2,
  "warning_count": 5,
  "backend_issues": [
    { "id": "C1", "severity": "critical", "file": "server/controllers/userController.js", "line": 45, "issue": "Password in response" },
    { "id": "W3", "severity": "warning", "file": "server/models/Post.js", "issue": "Missing author index" }
  ],
  "frontend_issues": [
    { "id": "C2", "severity": "critical", "file": "client/src/pages/AdminPage.jsx", "issue": "No role check" },
    { "id": "W2", "severity": "warning", "file": "client/src/components/PostList.jsx", "issue": "useEffect missing dependency" }
  ]
}
```
