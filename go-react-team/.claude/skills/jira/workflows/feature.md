# Workflow: Create Feature Tickets

Use this playbook when creating Jira tickets for a new feature, whether from a PRD, a user request, or a technical specification.

## Steps

### 1. Parse the Request

Extract from the input:
- **Feature name** — what is being built
- **Scope** — backend, frontend, fullstack, infrastructure
- **Acceptance criteria** — what "done" looks like
- **Priority** — urgency and business impact
- **Dependencies** — existing issues this relates to or is blocked by
- **Target project** — Jira project key
- **Target Epic** — existing Epic to attach to, or create a new one

If any critical information is missing, ask before proceeding. Do not invent acceptance criteria.

### 2. Search for Duplicates

Before creating anything, run a duplicate-detection query:

```jql
project = {PROJECT} AND summary ~ "{keywords}" AND status != Done
```

If potential duplicates are found, report them and ask whether to proceed, link, or abort.

### 3. Validate Fields

Confirm the following exist in the target project:
- Project key is valid
- Issue types are available (Epic, Story, Sub-task)
- Components referenced exist
- Labels are consistent with existing conventions (check existing labels first)

### 4. Decompose the Feature

Apply the decomposition pattern appropriate to the scope:

#### Fullstack Feature Decomposition

```
Epic: [Feature Name]
├── Story: [User-facing capability]
│   ├── Sub-task: Backend — [API endpoint / service logic]
│   ├── Sub-task: Backend — [Database migration / schema]
│   ├── Sub-task: Frontend — [UI component]
│   ├── Sub-task: Frontend — [State management / API integration]
│   └── Sub-task: Testing — [Integration / E2E tests]
├── Story: [Another user-facing capability]
│   ├── Sub-task: ...
│   └── Sub-task: ...
└── Task: [Non-user-facing technical work]
    ├── Sub-task: ...
    └── Sub-task: ...
```

#### Decomposition Rules

| Scope | Epic? | Stories | Sub-task Pattern |
|-------|-------|---------|-----------------|
| **Fullstack feature** | Yes (new or existing) | 1 per user-facing capability | Backend + Frontend + Testing per Story |
| **Backend only** | Attach to existing | 1 per API endpoint or service | Endpoint, migration, tests |
| **Frontend only** | Attach to existing | 1 per screen or user flow | Component, state, integration tests |
| **Infrastructure** | Optional | Tasks instead of Stories | Config, deployment, monitoring |
| **Small feature** | Attach to existing | 1 Story, no sub-tasks | Only if < 1 day of work |

#### Estimation Guide

| Sub-task Effort | Story Points |
|----------------|-------------|
| Trivial (< 2 hours) | 1 |
| Small (half day) | 2 |
| Medium (1 day) | 3 |
| Large (2-3 days) | 5 |
| Very large (1 week) | 8 |
| Should be split further | 13 |

### 5. Create Issues

Execute in order (parents before children):

1. **Create Epic** (if needed) via `jira_create_issue`
   - Summary: Feature name in imperative mood
   - Description: High-level feature description, goals, success metrics
   - Priority: As determined in Step 1
   - Labels: Feature area labels

2. **Create Stories** via `jira_create_issue`
   - Summary: User-facing capability in imperative mood
   - Description: Using the Story template from SKILL.md
   - Epic Link: The Epic from step 1
   - Priority: Inherit from Epic or override per story
   - Labels: Scope labels (backend, frontend, etc.)
   - Story Points: Sum of expected sub-task effort

3. **Create Sub-tasks** via `jira_create_issue`
   - Summary: Prefix with scope — "Backend: ...", "Frontend: ...", "Testing: ..."
   - Parent: The Story from step 2
   - Description: Technical details, specific implementation notes
   - Priority: Inherit from parent Story

4. **Link related issues** via `jira_link_issues`
   - Link to dependencies (blocks / is blocked by)
   - Link to related work (relates to)

5. **Add context comments** via `jira_add_comment`
   - Reference the source (PRD section, user request, Slack thread)
   - Note any decisions made during decomposition

### 6. Report Result

Output using FORMAT.md structure:
- Table of all created issues with keys, types, summaries, and parent relationships
- Any links created
- Any comments added
- Quality checklist

Then delegate to el-capitan if running in a pipeline.

## Example: Fullstack Feature

**Input**: "We need user authentication with email/password login and password reset"

**Output**:
```
Searched for duplicates: summary ~ "authentication" AND project = PROJ — 0 found.

Created 7 issues:

| Key | Type | Summary | Parent | Points |
|-----|------|---------|--------|--------|
| [PROJ-200] | Epic | Implement user authentication system | — | — |
| [PROJ-201] | Story | Add email/password login | PROJ-200 | 8 |
| [PROJ-202] | Sub-task | Backend: POST /auth/login endpoint | PROJ-201 | — |
| [PROJ-203] | Sub-task | Backend: User credentials schema and migration | PROJ-201 | — |
| [PROJ-204] | Sub-task | Frontend: Login form with validation | PROJ-201 | — |
| [PROJ-205] | Sub-task | Frontend: Auth state management and token storage | PROJ-201 | — |
| [PROJ-206] | Sub-task | Testing: Login flow E2E tests | PROJ-201 | — |

Linked: [PROJ-201] relates to [PROJ-150]
Commented on [PROJ-201]: "Source: PRD v2.1, Section 3 — Authentication Requirements."
```

## Checklist

- [ ] Duplicates checked before creation
- [ ] Feature decomposed per scope rules
- [ ] Epic created or linked
- [ ] Stories have description templates filled
- [ ] Sub-tasks prefixed with scope (Backend/Frontend/Testing)
- [ ] Summaries under 80 chars, imperative mood
- [ ] Priority explicitly set on all issues
- [ ] Labels and components assigned
- [ ] Dependencies linked
- [ ] Source/context captured in comments
- [ ] Output matches FORMAT.md
