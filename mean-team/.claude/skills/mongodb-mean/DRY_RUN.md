# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze
- Read the PRD to extract all entities, their fields, and relationships
- Identify access patterns implied by each feature (which queries will be frequent)
- Determine embedding vs referencing strategy for each relationship
- Check for existing models in the codebase that may need modification

## What to Output

### 1. Collections Inventory

```markdown
| Collection | Source (PRD Feature) | Estimated Fields | Strategy |
|------------|---------------------|-----------------|----------|
| users | F1, F2 | 6-8 fields | New collection |
| posts | F3, F4 | 5-7 fields | New collection |
| comments | F5 | 3-4 fields | Embed in posts |
```

### 2. Relationship Map

```markdown
| From | To | Type | Embed or Reference | Rationale |
|------|----|------|-------------------|-----------|
| Post | User | many-to-one | Reference | Independent access, high cardinality |
| Comment | Post | many-to-one | Embed | Always read together, low cardinality |
```

### 3. Index Plan

```markdown
| Collection | Index | Query Pattern |
|------------|-------|--------------|
| users | { email: 1 } unique | Login lookup |
| posts | { author: 1, createdAt: -1 } | User's posts feed |
```

### 4. Design Questions
Numbered list of decisions that need clarification:
1. Should comments be embedded or referenced? (depends on expected volume)
2. Soft delete or hard delete for posts?
3. Are tags a separate collection or an array of strings on posts?

### 5. Risk Flags
1. [PERF] PRD mentions "search by keyword" — may need text index or external search
2. [SCHEMA] PRD has no explicit role definitions — assuming 'user' and 'admin'

## What NOT to Do
- DO NOT write Mongoose schema code
- DO NOT create any files on disk
- DO NOT produce complete field-level definitions (just field counts and key fields)
- DO NOT install packages or modify package.json
- DO still read the PRD and existing codebase to make real design decisions
