# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

The PM skill produces two distinct output formats depending on the operating mode.

---

## Mode A: PRD Document (Phase 0)

The PRD is written to `docs/prd.md` and follows this exact structure.

### Required Sections

#### 1. Header

```markdown
# Product Requirements Document
**Project:** {project name}
**Version:** {1.0 | incremental}
**Date:** {YYYY-MM-DD}
**Author:** pm-fullstack
**Status:** Draft | Approved
```

#### 2. Overview

```markdown
## Overview

### Problem Statement
{1-3 sentences describing what problem we are solving and for whom.}

### Goals
- {Goal 1: measurable outcome}
- {Goal 2: measurable outcome}

### Success Metrics
- {Metric 1: quantifiable measure of success}
- {Metric 2: quantifiable measure of success}
```

#### 3. Features

Each feature is a separate subsection under `## Features`. Every feature follows this structure exactly:

```markdown
## Features

### F-001: {Feature Name}
**Priority:** P0 | P1 | P2
**Description:** {What this feature does from the user's perspective.}

#### User Stories
- As a {role}, I want {capability}, so that {benefit}.
- As a {role}, I want {capability}, so that {benefit}.

#### Acceptance Criteria
- **AC-001-01:** GIVEN {context}, WHEN {action}, THEN {expected result}.
- **AC-001-02:** GIVEN {context}, WHEN {action}, THEN {expected result}.
- **AC-001-03:** GIVEN {error condition}, WHEN {action}, THEN {error handling behavior}.

#### Technical Notes
{Any constraints or considerations the architect/developers need to know. NOT implementation instructions — just "what" constraints like "must support concurrent access" or "response time under 200ms".}
```

#### 4. Technical Constraints

```markdown
## Technical Constraints

### Stack
- **Backend:** Go (specify minimum version if relevant)
- **Frontend:** React (specify minimum version if relevant)
- **Database:** {PostgreSQL | MySQL | SQLite | etc.}
- **Authentication:** {JWT | OAuth2 | session-based | etc.}

### API Contract Requirements
- {e.g., "All API responses must follow the standard envelope: { data, error, meta }"}
- {e.g., "All endpoints must return appropriate HTTP status codes (201 for creation, 404 for not found, etc.)"}

### Non-Functional Requirements
- {Performance: e.g., "API responses under 500ms for 95th percentile"}
- {Security: e.g., "All user input must be validated server-side"}
- {Accessibility: e.g., "WCAG 2.1 AA compliance for all UI components"}
```

#### 5. Priorities Summary

```markdown
## Priorities Summary

| ID    | Feature             | Priority | Complexity |
|-------|---------------------|----------|------------|
| F-001 | {Feature Name}      | P0       | {Low/Med/High} |
| F-002 | {Feature Name}      | P1       | {Low/Med/High} |
```

#### 6. Out of Scope

```markdown
## Out of Scope
- {Thing explicitly NOT included in this iteration}
- {Thing explicitly NOT included in this iteration}
```

#### 7. Open Questions

```markdown
## Open Questions
- {Question that needs user clarification before or during implementation}
- {Ambiguity that the PM could not resolve from the request alone}
```

### PRD Quality Checklist

```markdown
- [ ] Every feature has a unique ID (F-XXX)
- [ ] Every feature has at least one user story
- [ ] Every feature has at least two acceptance criteria (happy path + error case)
- [ ] Every acceptance criterion uses GIVEN/WHEN/THEN format
- [ ] Every acceptance criterion is testable (no subjective language)
- [ ] Priorities are assigned to every feature (P0/P1/P2)
- [ ] Technical constraints section is complete
- [ ] Out of scope section is present (even if empty with "None identified")
- [ ] No implementation details leak into the PRD (no "use X library" or "implement with Y pattern")
- [ ] Feature IDs and AC IDs are consistent and sequential
```

---

## Mode B: Acceptance Review Report (Phase 6)

The review report is written to `docs/acceptance-review.md` and follows this exact structure.

### Required Sections

#### 1. Header

```markdown
# Acceptance Review Report
**PRD Reference:** docs/prd.md
**Review Date:** {YYYY-MM-DD}
**Reviewer:** pm-fullstack
**Verdict:** ACCEPT | REJECT | ACCEPT WITH CONDITIONS
```

#### 2. Summary

```markdown
## Summary
{2-4 sentences: what was requested, what was delivered, overall assessment.}

### Statistics
- **Total Acceptance Criteria:** {N}
- **Passed:** {N} ({percentage}%)
- **Failed:** {N} ({percentage}%)
- **Partial:** {N} ({percentage}%)
```

#### 3. Criteria Evaluation

```markdown
## Criteria Evaluation

### F-001: {Feature Name}

| Criterion  | Verdict | Evidence |
|------------|---------|----------|
| AC-001-01  | PASS    | {File or test that proves this criterion is met} |
| AC-001-02  | FAIL    | {What is missing or incorrect} |
| AC-001-03  | PARTIAL | {What works, what doesn't} |

**Feature Verdict:** PASS | FAIL | PARTIAL
**Notes:** {Any context about this feature's delivery}

### F-002: {Feature Name}
{Same table structure}
```

#### 4. Issues

```markdown
## Issues

### Critical (blocks acceptance)
- **[CRITICAL] {Issue title}** — {Description. Reference AC-XXX-XX.}

### Warnings (should be addressed)
- **[WARN] {Issue title}** — {Description. Reference AC-XXX-XX.}

### Observations (non-blocking)
- **[INFO] {Issue title}** — {Observation or suggestion.}
```

#### 5. Verdict

```markdown
## Verdict

**Decision:** ACCEPT | REJECT | ACCEPT WITH CONDITIONS

**Rationale:** {2-3 sentences explaining the decision.}

### Conditions (if ACCEPT WITH CONDITIONS)
- {Condition 1: what must be fixed before final delivery}
- {Condition 2: what must be fixed before final delivery}

### Recommendations
- {Recommendation for improvement in next iteration}
```

### Review Quality Checklist

```markdown
- [ ] Every acceptance criterion from the PRD is evaluated
- [ ] Every evaluation has a clear PASS/FAIL/PARTIAL verdict
- [ ] Every FAIL and PARTIAL has specific evidence or explanation
- [ ] Every PASS references a concrete file, test, or artifact
- [ ] Critical issues reference specific AC IDs
- [ ] Overall verdict is consistent with individual evaluations
- [ ] No P0 criteria are marked FAIL if overall verdict is ACCEPT
```

---

## Output Summary (for el-capitan delegation)

Regardless of mode, the final message to el-capitan must include:

```markdown
### PM Phase Complete

**Mode:** Phase 0 (PRD) | Phase 6 (Acceptance Review)
**Output File:** {path to generated document}
**Status:** Complete | Complete with open questions

**Files Created/Modified:**
| File | Purpose | Status |
|------|---------|--------|
| docs/prd.md | Product Requirements Document | created |

**Key Metrics:**
- {Features defined: N | Criteria evaluated: N}
- {Open questions: N | Failures: N}

**Recommendations for Next Phase:**
- {What the next agent in the pipeline needs to know}
```
