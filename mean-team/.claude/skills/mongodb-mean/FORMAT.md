# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Summary
1-3 sentences: number of collections designed, key design decisions (embedding vs referencing), and alignment with PRD entities.

### 2. Collections Overview

```markdown
| Collection | Purpose | Key Fields | Indexes |
|------------|---------|-----------|---------|
| users | User accounts and auth | email, passwordHash, role | email (unique) |
| posts | User-generated content | title, body, author | author, createdAt |
```

### 3. Schema Definitions
For each collection, provide the full Mongoose schema as working code:

```javascript
// models/User.js
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  passwordHash: { type: String, required: true },
  role: { type: String, enum: ['user', 'admin'], default: 'user' },
  createdAt: { type: Date, default: Date.now }
});
```

### 4. Index Definitions

```markdown
| Collection | Index | Fields | Type | Rationale |
|------------|-------|--------|------|-----------|
| users | email_unique | { email: 1 } | unique | Login lookup, duplicate prevention |
| posts | author_date | { author: 1, createdAt: -1 } | compound | User's posts sorted by date |
```

### 5. Relationship Map
Document how collections relate to each other:

```markdown
| From | To | Type | Strategy | Field |
|------|----|------|----------|-------|
| Post | User | many-to-one | reference | author (ObjectId) |
| Comment | Post | many-to-one | embed | embedded in Post.comments[] |
| User | Role | one-to-one | inline | role (String enum) |
```

### 6. Design Decisions
Numbered list explaining key choices:

```markdown
1. **Embed comments in posts** — Comments are always read with their parent post, low cardinality expected (<100 per post), no independent access pattern needed.
2. **Reference author in posts** — Users are accessed independently, high cardinality, shared across posts.
3. **String enum for roles** — Only 2-3 roles expected, no need for separate roles collection.
```

### 7. Quality Checklist

- [ ] Every PRD entity has a corresponding collection or embedded document
- [ ] Every collection has at least one index beyond `_id`
- [ ] All reference fields use `mongoose.Schema.Types.ObjectId` with `ref`
- [ ] Required fields marked with `required: true`
- [ ] String fields have appropriate validators (enum, minlength, maxlength, match)
- [ ] Timestamps strategy consistent (createdAt/updatedAt or `timestamps: true`)
- [ ] Embedding vs referencing decision documented for every relationship
- [ ] Indexes support the query patterns implied by PRD features

## Files Created/Modified

```markdown
| File | Purpose | Status |
|------|---------|--------|
| server/models/User.js | User schema and model | created |
| server/models/Post.js | Post schema and model | created |
```

## Issues & Recommendations
Numbered list with severity flags. See VOICE.md for flag definitions.
