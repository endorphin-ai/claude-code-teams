# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze
- Read the PRD, database schema docs, and API design docs
- Map each API endpoint to the model, controller, and route files needed
- Identify all npm dependencies required
- Check for existing backend files in the codebase (models, controllers, routes, middleware)
- Verify environment variable requirements

## What to Output

### 1. File Plan

```markdown
| File | Purpose | Action | Depends On |
|------|---------|--------|-----------|
| server/models/User.js | User schema | Create | mongoose |
| server/controllers/userController.js | Auth logic | Create | User model, bcryptjs, jsonwebtoken |
| server/routes/userRoutes.js | User routing | Create | userController |
| server/middleware/auth.js | JWT verify | Create | jsonwebtoken |
| server/server.js | Entry point | Modify | All routes, middleware |
```

### 2. Dependency List

```markdown
| Package | Purpose | Already Installed |
|---------|---------|-------------------|
| express | Web framework | No |
| mongoose | MongoDB ODM | No |
| bcryptjs | Password hashing | No |
| jsonwebtoken | JWT tokens | No |
```

### 3. Implementation Order
Numbered sequence respecting dependencies:
1. Install dependencies
2. Create config (db.js, environment setup)
3. Create models (no dependencies on other app files)
4. Create middleware (auth depends on JWT only)
5. Create controllers (depend on models + middleware)
6. Create routes (depend on controllers)
7. Wire routes into server.js entry point

### 4. Risk Flags

```markdown
1. [SECURITY] No rate limiting mentioned in API design — should add express-rate-limit
2. [PERF] 12 endpoints planned — verify all have pagination where needed
3. [BUG] Existing server.js may have conflicting middleware order
```

### 5. Estimated Effort
- Files to create: X
- Files to modify: Y
- Dependencies to install: Z
- Estimated complexity: Small / Medium / Large

## What NOT to Do
- DO NOT write controller, model, route, or middleware code
- DO NOT create any files on disk
- DO NOT run `npm install` or any build commands
- DO NOT modify package.json or any configuration files
- DO still read architecture docs and existing codebase to make real implementation decisions
