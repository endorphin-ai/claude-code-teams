# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Summary
1-3 sentences: what was implemented, number of files created/modified, and key decisions made.

### 2. Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| server/models/User.js | User schema with bcrypt hooks | created |
| server/controllers/userController.js | Auth handlers (register, login) | created |
| server/routes/userRoutes.js | User endpoint routing | created |
| server/middleware/auth.js | JWT verification middleware | created |
| server/config/db.js | MongoDB connection setup | created |
| server/server.js | Express app entry point | modified |
```

### 3. Dependencies Installed

```markdown
| Package | Version | Purpose |
|---------|---------|---------|
| express | ^4.18.x | Web framework |
| mongoose | ^7.x | MongoDB ODM |
| bcryptjs | ^2.4.x | Password hashing |
| jsonwebtoken | ^9.x | JWT auth tokens |
| dotenv | ^16.x | Environment variables |
```

### 4. API Endpoints Implemented

```markdown
| Method | Endpoint | Controller | Auth | Status |
|--------|----------|-----------|------|--------|
| POST | /api/users/register | userController.register | Public | implemented |
| POST | /api/users/login | userController.login | Public | implemented |
| GET | /api/users/me | userController.getMe | Protected | implemented |
| GET | /api/posts | postController.getAll | Protected | implemented |
```

### 5. Environment Variables

```markdown
| Variable | Purpose | Default | Required |
|----------|---------|---------|----------|
| PORT | Server port | 5000 | No |
| MONGODB_URI | Database connection string | — | Yes |
| JWT_SECRET | Token signing key | — | Yes |
| JWT_EXPIRE | Token expiration | 30d | No |
```

### 6. Quality Checklist

- [ ] All models match the database schema docs
- [ ] All endpoints match the API design docs
- [ ] Auth middleware applied to all protected endpoints
- [ ] Passwords hashed before storage (bcrypt)
- [ ] JWT tokens generated with appropriate expiration
- [ ] Input validation on all request bodies
- [ ] Error handling follows centralized errorHandler pattern
- [ ] No secrets hardcoded — all in environment variables
- [ ] CORS configured for frontend origin
- [ ] Server starts cleanly with `npm run dev`

### 7. Issues & Recommendations
Numbered list with severity flags:

```markdown
1. [SECURITY] Rate limiting not implemented on login endpoint — add express-rate-limit
2. [PERF] No pagination on GET /api/posts — will degrade with large datasets
3. [BUG] Missing error handling in db.js for connection retry
```
