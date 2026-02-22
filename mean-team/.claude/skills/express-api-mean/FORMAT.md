# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Summary
1-3 sentences: number of endpoints designed, resource groups, auth strategy, and alignment with PRD features.

### 2. Endpoint Overview

```markdown
| Method | Endpoint | Purpose | Auth | PRD Feature |
|--------|----------|---------|------|-------------|
| POST | /api/users/register | Create new user account | Public | F1 |
| POST | /api/users/login | Authenticate and return JWT | Public | F2 |
| GET | /api/posts | List posts with pagination | Authenticated | F3 |
| GET | /api/posts/:id | Get single post by ID | Authenticated | F3 |
| POST | /api/posts | Create new post | Authenticated | F4 |
| PUT | /api/posts/:id | Update own post | Owner | F4 |
| DELETE | /api/posts/:id | Delete own post | Owner | F4 |
```

### 3. Endpoint Contracts
For each endpoint, provide the full request/response contract:

```markdown
#### POST /api/users/register

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "data": {
    "user": { "id": "...", "email": "...", "name": "..." },
    "token": "eyJhbGci..."
  }
}
```

**Error Responses:**
- 400: `{ "success": false, "error": "Email already registered" }`
- 422: `{ "success": false, "error": "Validation failed", "details": [...] }`
```

### 4. Middleware Chain
Ordered list of middleware applied globally and per-route:

```markdown
| Middleware | Scope | Purpose |
|-----------|-------|---------|
| express.json() | Global | Parse JSON request bodies |
| cors | Global | Cross-origin request handling |
| helmet | Global | Security headers |
| auth | Per-route | JWT verification, attaches req.user |
| validate | Per-route | Request body validation |
| errorHandler | Global (last) | Centralized error response formatting |
```

### 5. Auth Flow
Step-by-step description of the authentication flow:

1. User sends POST /api/users/login with email + password
2. Server verifies credentials against database
3. Server generates JWT with user ID and role in payload
4. Client stores token and sends as `Authorization: Bearer <token>` header
5. Auth middleware verifies token on protected endpoints
6. Auth middleware attaches decoded user to `req.user`

### 6. Error Handling Strategy
Consistent error response format used across all endpoints:

```json
{
  "success": false,
  "error": "Human-readable error message",
  "details": ["field-level errors if applicable"]
}
```

Standard HTTP status codes:
- 200: Success (GET, PUT)
- 201: Created (POST)
- 204: No Content (DELETE)
- 400: Bad Request (validation, duplicate)
- 401: Unauthorized (missing/invalid token)
- 403: Forbidden (insufficient role)
- 404: Not Found
- 500: Internal Server Error

### 7. Design Decisions
Numbered list explaining key API design choices:

```markdown
1. **Separate register and login endpoints** — Registration returns a token immediately so users don't need a second request to log in.
2. **Owner-only update/delete** — Middleware checks req.user.id against resource.author before allowing mutations.
3. **Pagination on list endpoints** — Default page=1, limit=20. Returns total count in response for client-side pagination.
```

### 8. Quality Checklist

- [ ] Every PRD feature has at least one endpoint
- [ ] All endpoints follow RESTful naming (plural nouns, no verbs in paths)
- [ ] Every endpoint has a documented request/response contract
- [ ] Auth level specified and enforced per endpoint
- [ ] Error responses follow consistent format
- [ ] Validation defined for all request bodies
- [ ] Pagination implemented on list endpoints
- [ ] No business logic in route files (delegated to controllers)

## Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| server/routes/users.js | User auth endpoints | created |
| server/routes/posts.js | Post CRUD endpoints | created |
| server/middleware/auth.js | JWT verification | created |
| server/middleware/errorHandler.js | Centralized errors | created |
```

## Issues & Recommendations
Numbered list with severity flags. See VOICE.md for flag definitions.
