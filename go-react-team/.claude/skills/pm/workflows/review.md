# Workflow: Acceptance Review (Phase 6)

Use this playbook when performing acceptance review of delivered work against the PRD.
This is the PM's Phase 6 responsibility — the final quality gate before delivery to the user.

## Prerequisites

- A completed PRD at `docs/prd.md` (written during Phase 0)
- Delivered code and artifacts from the development pipeline (Go backend, React frontend, tests)
- Test results from the testing phases (if available)

## Steps

### 1. Load the PRD

Read `docs/prd.md` in full. Extract a master list of every acceptance criterion with its ID, feature, priority, and the GIVEN/WHEN/THEN specification. This list is your review checklist.

Build a working table:

```
| Criterion ID | Feature | Priority | GIVEN/WHEN/THEN Summary | Verdict | Evidence |
```

Initialize all Verdict cells as "PENDING".

### 2. Inventory Deliverables

Scan the codebase to catalog what was delivered. Build an inventory of:

**Backend (Go):**
- Handlers / route definitions
- Service/business logic files
- Repository/database access files
- Middleware (auth, logging, CORS, etc.)
- Database migrations or schema definitions
- Configuration files
- Go test files

**Frontend (React):**
- Page/route components
- UI components
- API client/service files
- State management (stores, contexts, hooks)
- Style files
- React test files

**Cross-cutting:**
- Documentation files
- Configuration files (docker-compose, .env templates, etc.)
- CI/CD definitions

Record each file's path, type, and which feature(s) it likely relates to.

### 3. Map Criteria to Evidence

For each acceptance criterion, find the concrete evidence that it is satisfied:

- **Code evidence:** A handler, component, or logic file that implements the specified behavior
- **Test evidence:** A test case that verifies the GIVEN/WHEN/THEN condition
- **Configuration evidence:** A config file that establishes the required constraint (e.g., CORS policy, rate limits)

Evidence must be specific: reference file paths and, where possible, function names or test names. "The auth module handles this" is not evidence. "`internal/handler/auth.go:HandleLogin` validates credentials and returns JWT via `POST /api/auth/login`" is evidence.

### 4. Evaluate Each Criterion

For every acceptance criterion, assign a verdict:

**PASS** — All of these must be true:
- Code exists that implements the specified behavior
- The implementation matches the GIVEN/WHEN/THEN specification
- Error cases specified in the criterion are handled
- If a test exists for this criterion, the test is meaningful (not a stub)

**FAIL** — Any of these means FAIL:
- No code exists that addresses this criterion
- The implementation contradicts the specification (e.g., returns 200 instead of specified 201)
- A critical aspect of the criterion is missing (e.g., criterion specifies error handling but none exists)
- The code exists but is clearly non-functional (compile errors, logic errors visible on inspection)

**PARTIAL** — The criterion is partially met:
- The happy path works but the error case specified in the criterion is not handled
- The implementation exists but deviates from the specification in a minor way
- The code exists but lacks the test coverage expected for this criterion

### 5. Assess Features Holistically

After evaluating individual criteria, assess each feature as a whole:

- **Feature PASS:** All criteria for this feature are PASS
- **Feature FAIL:** Any P0-priority criterion for this feature is FAIL, OR more than half of criteria are FAIL
- **Feature PARTIAL:** Some criteria are FAIL or PARTIAL, but the core functionality works

### 6. Identify Cross-Cutting Issues

Look beyond individual criteria for systemic issues:

- **Consistency:** Do error responses follow a consistent format across all endpoints?
- **Security:** Are there obvious security gaps (unvalidated input, missing auth checks, exposed secrets)?
- **Quality:** Is the code structured and readable, or does it appear rushed/incomplete?
- **Completeness:** Are there obvious features that were partially implemented and abandoned?
- **Technical Constraints:** Do the non-functional requirements from the PRD appear to be met (response format, validation, etc.)?

### 7. Determine Overall Verdict

Apply these rules strictly:

**REJECT** if:
- Any P0 acceptance criterion is FAIL
- More than 30% of all criteria are FAIL
- A critical cross-cutting issue exists (e.g., no authentication when auth is required)

**ACCEPT WITH CONDITIONS** if:
- All P0 criteria are PASS
- Some P1 criteria are FAIL or PARTIAL
- Issues exist but are bounded and fixable
- List specific conditions that must be met before final acceptance

**ACCEPT** if:
- All P0 criteria are PASS
- All P1 criteria are PASS or PARTIAL
- P2 failures are noted but do not block
- No critical cross-cutting issues

### 8. Write the Review Report

Assemble the complete acceptance review report following FORMAT.md's Mode B specification exactly:

1. Header (PRD reference, review date, reviewer, verdict)
2. Summary (what was requested, what was delivered, overall assessment, statistics)
3. Criteria Evaluation (per-feature tables with verdict and evidence)
4. Issues (categorized as CRITICAL / WARN / INFO)
5. Verdict (decision, rationale, conditions if applicable, recommendations)

Save the review report to `docs/acceptance-review.md`.

### 9. Self-Review

Before reporting completion, verify:
- Every acceptance criterion from the PRD is accounted for (none skipped)
- Every FAIL has specific, actionable evidence
- Every PASS has a concrete file/artifact reference
- The overall verdict is logically consistent with individual evaluations
- Issue severity levels (CRITICAL/WARN/INFO) match the actual impact
- The report follows FORMAT.md structure exactly

### 10. Report to El-Capitan

Prepare the delegation message following FORMAT.md's output summary structure. Include:
- Mode: Phase 6 (Acceptance Review)
- Output file path
- Overall verdict
- Pass/fail/partial statistics
- Critical issues count
- Recommendation: whether to deliver to user, or what needs to be fixed first

## Checklist

- [ ] PRD loaded and all acceptance criteria inventoried
- [ ] Codebase scanned and deliverables cataloged
- [ ] Every criterion mapped to evidence (or marked as having no evidence)
- [ ] Every criterion evaluated as PASS / FAIL / PARTIAL with justification
- [ ] Features assessed holistically
- [ ] Cross-cutting issues identified
- [ ] Overall verdict determined using the defined rules
- [ ] Review report follows FORMAT.md Mode B structure exactly
- [ ] Review report saved to `docs/acceptance-review.md`
- [ ] No acceptance criterion from the PRD was skipped
- [ ] Delegation message prepared for el-capitan
