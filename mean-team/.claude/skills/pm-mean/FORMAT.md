# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

This skill has two modes. Use Mode 1 when writing a PRD. Use Mode 2 when reviewing deliverables.

---

## Mode 1: PRD Output

### 1. Summary
1-3 sentences: what the app does, target user, core value proposition.

### 2. Features Table

```markdown
| # | Feature | Priority | Auth | Description |
|---|---------|----------|------|-------------|
| F1 | User Registration | **Must** | Public | New users create accounts with email/password |
| F2 | User Login | **Must** | Public | Existing users authenticate via JWT |
| F3 | Dashboard | **Should** | Authenticated | User sees personalized overview |
```

### 3. Feature Details
For each feature (F1, F2, ...), provide:

```markdown
#### F1: Feature Name
**Priority:** Must | Should | Could | Won't
**Auth:** Public | Authenticated | Admin

**User Story:**
As a [role], I want to [action] so that [benefit].

**Acceptance Criteria:**
- Given [context], when [action], then [result]
- Given [context], when [error condition], then [error result]
```

### 4. Data Model Summary
High-level entities and their relationships. Table format:

```markdown
| Entity | Key Fields | Relationships |
|--------|-----------|---------------|
| User | email, password, role | has many Posts |
| Post | title, body, author | belongs to User |
```

### 5. API Summary
Key endpoints grouped by resource:

```markdown
| Method | Endpoint | Purpose | Auth |
|--------|----------|---------|------|
| POST | /api/users/register | Create account | Public |
| POST | /api/users/login | Authenticate | Public |
| GET | /api/posts | List all posts | Authenticated |
```

### 6. UI Summary
Key pages and user flows:

```markdown
| Page | Route | Purpose | Auth |
|------|-------|---------|------|
| Landing | / | Marketing page | Public |
| Login | /login | User authentication | Public |
| Dashboard | /dashboard | User overview | Authenticated |
```

### 7. Technical Constraints
- Auth method (JWT)
- Database (MongoDB)
- Deployment target
- Performance requirements
- Third-party integrations

### 8. Priorities
MoSCoW summary:

```markdown
**Must:** F1, F2, F5
**Should:** F3, F6
**Could:** F4, F7
**Won't (this version):** F8
```

---

## Mode 2: Acceptance Review Output

### 1. Verdict
One line: **PASS** or **FAIL** with brief rationale.

### 2. Feature Checklist

```markdown
| # | Feature | Status | Notes |
|---|---------|--------|-------|
| F1 | User Registration | PASS | All acceptance criteria met |
| F2 | User Login | FAIL | Missing password reset flow |
| F3 | Dashboard | PARTIAL | Stats display works, charts missing |
```

### 3. Issues
Numbered list of issues found, each with severity flag:

```markdown
1. [CRITICAL] F2: Password reset endpoint returns 500 — users cannot recover accounts
2. [WARN] F3: Dashboard chart component renders but shows no data on first load
3. [INFO] F1: Registration success message could be more descriptive
```

### 4. Recommendations
Numbered list of actionable next steps to reach PASS:

```markdown
1. Fix password reset controller error handling (F2 blocker)
2. Add data fetching to dashboard chart useEffect (F3)
3. Improve registration success UX copy (F1, low priority)
```

---

## Quality Checklist (both modes)

- [ ] Every feature has a unique number (F1, F2...)
- [ ] Every feature has MoSCoW priority assigned
- [ ] Every feature has at least one acceptance criterion in Given/When/Then format
- [ ] Auth level specified per feature
- [ ] Error scenarios included in acceptance criteria
- [ ] Data model covers all features
- [ ] API endpoints cover all features
- [ ] UI pages cover all user-facing features
