# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze
- Parse the user request to extract all mentioned features, behaviors, and constraints
- Identify the domain (e-commerce, social, SaaS, etc.) and typical entities for that domain
- Determine implied features the user likely needs but did not mention (auth, error handling, etc.)
- Assess scope: small (3-5 features), medium (6-10), large (11+)

## What to Output

### 1. Feature Inventory
```markdown
| # | Feature | Priority | Source |
|---|---------|----------|--------|
| F1 | User Auth | **Must** | Explicit — user mentioned login |
| F2 | Dashboard | **Should** | Explicit — user mentioned overview |
| F3 | Error Pages | **Must** | Implied — standard for any web app |
```

### 2. Scope Estimate
- Feature count: X explicit + Y implied = Z total
- Estimated complexity: Small / Medium / Large
- Estimated entities: list of likely data model entities
- Estimated pages: list of likely UI pages

### 3. Architecture Signals
- Auth pattern: JWT with refresh tokens (standard MEAN)
- Data relationships: one-to-many, many-to-many detected
- Real-time needs: yes/no (Socket.io consideration)
- File uploads: yes/no
- Third-party integrations: list any mentioned

### 4. Risk Flags
Numbered list of concerns:
1. [WARN] User mentioned "real-time chat" — adds Socket.io complexity
2. [INFO] No deployment target specified — will default to generic Node.js

### 5. Questions for User
Numbered list of clarifications needed before writing the full PRD:
1. What roles exist? (admin, regular user, moderator?)
2. Is email verification required for registration?
3. What is the deployment target? (Heroku, AWS, VPS?)

## What NOT to Do
- DO NOT write a full PRD document
- DO NOT create any files on disk
- DO NOT generate complete acceptance criteria (just feature names and priorities)
- DO NOT produce data model schemas or API contracts
- DO still read the user request carefully and make real analytical decisions
