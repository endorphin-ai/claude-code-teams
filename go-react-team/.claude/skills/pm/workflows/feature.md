# Workflow: PRD Writing (Phase 0)

Use this playbook when writing a Product Requirements Document from a user request.
This is the PM's Phase 0 responsibility — the PRD produced here is the single source of truth for all downstream agents.

## Prerequisites

- A user request describing what they want built (can range from a single sentence to a detailed brief)
- Knowledge of the target stack: Go backend + React frontend

## Steps

### 1. Parse the User Request

Read the input carefully and extract:
- **Explicit requirements** — things the user directly asked for
- **Implicit requirements** — things that are obviously needed but not stated (e.g., if the user asks for "user accounts", authentication is implied)
- **Constraints** — any technical, time, or scope constraints mentioned
- **Ambiguities** — anything unclear or open to multiple interpretations

Write down your understanding in a scratch list before proceeding. Do not start the PRD until you have a clear mental model of the request.

### 2. Decompose into Features

Break the request into discrete features. Each feature should be:
- **Cohesive** — one feature = one logical capability (not "build the backend")
- **Deliverable** — a developer can implement this feature and demo it independently
- **Bounded** — clear where this feature starts and stops

Assign each feature an ID (F-001, F-002, etc.) and a preliminary priority:
- **P0** — the product does not work without this. Core functionality.
- **P1** — significantly improves the product. Should be in v1.
- **P2** — nice to have. Can be deferred to a future iteration.

### 3. Write User Stories

For each feature, write at least one user story in the format:
> As a [role], I want [capability], so that [benefit].

Guidelines:
- The role should be specific (e.g., "authenticated user", "admin", "first-time visitor"), not generic ("user")
- The capability should describe a behavior, not a UI element
- The benefit should explain WHY this matters to the user

### 4. Define Acceptance Criteria

For each feature, write acceptance criteria in GIVEN/WHEN/THEN format:
> GIVEN [precondition or context], WHEN [action performed], THEN [expected observable result].

Rules:
- **Minimum two criteria per feature:** at least one happy path and one error/edge case
- **Each criterion tests one thing** — if you use "AND" in the THEN clause, consider splitting
- **Use concrete values** — "the system returns HTTP 201 with the created user object" not "the system successfully creates the user"
- **Cover error cases** — what happens on invalid input, missing authentication, duplicate data, rate limits?
- **Cover edge cases** — empty lists, maximum lengths, concurrent access, special characters
- **Assign IDs** — AC-{feature}-{sequence}, e.g., AC-001-01, AC-001-02

### 5. Specify Technical Constraints

Document the non-negotiable technical boundaries:
- Stack versions and compatibility requirements
- API response format standards
- Authentication and authorization model
- Performance requirements (response times, throughput)
- Security requirements (input validation, data protection)
- Database and storage requirements

Do NOT specify implementation details. Write "API responses must return within 500ms" not "use Redis caching to achieve 500ms response times".

Flag areas where the architect needs to make a decision with `[ARCHITECT DECISION]`.

### 6. Define Scope Boundaries

Write the "Out of Scope" section:
- Explicitly list things that might seem related but are NOT included
- This prevents scope creep and sets expectations
- When in doubt, add it to Out of Scope rather than leaving it ambiguous

### 7. Catalog Open Questions

If the user request has ambiguities that you cannot resolve through reasonable inference:
- Write them as specific, answerable questions
- Tag each with the feature it affects
- Suggest a default assumption if the question is not answered before development starts

### 8. Assemble the PRD

Write the complete PRD following the FORMAT.md specification exactly:
1. Header (project name, version, date, author, status)
2. Overview (problem statement, goals, success metrics)
3. Features (each with ID, priority, description, user stories, acceptance criteria, technical notes)
4. Technical Constraints (stack, API contracts, non-functional requirements)
5. Priorities Summary (table)
6. Out of Scope
7. Open Questions

Save the PRD to `docs/prd.md`.

### 9. Self-Review

Before reporting completion, verify:
- Every feature has a unique sequential ID
- Every feature has user stories and acceptance criteria
- Every acceptance criterion uses GIVEN/WHEN/THEN and is testable
- No implementation details have leaked into the PRD
- The Out of Scope section exists and is meaningful
- The Priorities Summary table matches the feature details
- The PRD reads as a complete, standalone document

### 10. Report to El-Capitan

Prepare the delegation message following FORMAT.md's output summary structure. Include:
- Mode: Phase 0 (PRD)
- Output file path
- Feature count and total acceptance criteria count
- Number of open questions
- Recommendations for the architect (next phase)

## Checklist

- [ ] User request fully parsed (explicit, implicit, ambiguous items identified)
- [ ] Features decomposed with unique IDs and priorities
- [ ] Every feature has at least one user story
- [ ] Every feature has at least two acceptance criteria (happy path + error case)
- [ ] All acceptance criteria use GIVEN/WHEN/THEN format
- [ ] All acceptance criteria are testable with concrete values
- [ ] Technical constraints specified without implementation details
- [ ] Out of Scope section present and meaningful
- [ ] Open questions cataloged with affected features
- [ ] PRD follows FORMAT.md structure exactly
- [ ] PRD saved to `docs/prd.md`
- [ ] Delegation message prepared for el-capitan
