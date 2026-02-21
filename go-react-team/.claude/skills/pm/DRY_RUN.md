# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze

Perform the complete PM analysis as if writing a real PRD or conducting a real acceptance review:

### For Phase 0 (PRD Writing) Dry-Run
- Parse the user request thoroughly — extract every explicit and implied requirement
- Decompose into candidate features with preliminary IDs (F-001, F-002, etc.)
- Draft preliminary user stories for each feature
- Identify what acceptance criteria would be needed (list them, but they can be abbreviated)
- Assess complexity of each feature (Low / Medium / High)
- Identify technical constraints implied by the request
- Catalog ambiguities, gaps, and open questions in the request
- Determine what is explicitly or implicitly out of scope

### For Phase 6 (Acceptance Review) Dry-Run
- Read the PRD and inventory all acceptance criteria
- Scan the codebase to identify what files and artifacts exist
- Map criteria to potential evidence (which files likely satisfy which criteria)
- Identify criteria that appear to have no corresponding deliverable
- Identify deliverables that appear to have no corresponding criterion
- Flag areas that would require deeper inspection during a real review

## What to Output

### Phase 0 Dry-Run Report

```markdown
# PRD Dry-Run Analysis

## Request Summary
{2-3 sentence summary of what was requested}

## Candidate Features
| ID    | Feature Name        | Priority (est.) | Complexity (est.) | AC Count (est.) |
|-------|---------------------|------------------|--------------------|-----------------|
| F-001 | {Name}              | P0               | Medium             | 4               |
| F-002 | {Name}              | P1               | High               | 6               |

## Feature Details

### F-001: {Feature Name}
**Description:** {Brief description}
**Key User Stories:** {1-2 abbreviated stories}
**Sample Acceptance Criteria:**
- {Abbreviated criterion 1}
- {Abbreviated criterion 2}
**Complexity Rationale:** {Why this is Low/Medium/High}

## Identified Risks
- {Risk 1: what could go wrong or cause scope creep}
- {Risk 2: technical uncertainty}

## Open Questions (require user input)
- {Question 1: ambiguity in the request}
- {Question 2: missing information}

## Out of Scope (preliminary)
- {Item 1}
- {Item 2}

## Estimated PRD Scope
- **Features:** {N}
- **Total Acceptance Criteria:** ~{N}
- **Estimated Effort:** {Small / Medium / Large}

## Recommendation
{1-2 sentences: proceed as-is, or resolve questions first?}
```

### Phase 6 Dry-Run Report

```markdown
# Acceptance Review Dry-Run Analysis

## PRD Reference
**File:** {path to PRD}
**Features:** {N}
**Total Criteria:** {N}

## Deliverables Inventory
| File/Artifact | Type | Related Feature(s) |
|---------------|------|--------------------|
| {path}        | {Go handler / React component / test / etc.} | F-001 |

## Criteria Coverage Map
| Criterion  | Likely Evidence | Confidence |
|------------|-----------------|------------|
| AC-001-01  | {file or test}  | High       |
| AC-001-02  | {file or test}  | Medium     |
| AC-002-01  | None found      | N/A        |

## Risk Assessment
- **Criteria with no evidence:** {N}
- **Criteria with low confidence:** {N}
- **Uncovered features:** {list}

## Preliminary Assessment
{1-3 sentences: likely outcome of a full review based on surface analysis}
```

## What NOT to Do

- DO NOT create, modify, or delete any files (no `docs/prd.md`, no `docs/acceptance-review.md`)
- DO NOT produce a full PRD — only the analysis and plan
- DO NOT produce a full acceptance review — only the coverage map and risk assessment
- DO NOT install packages or run build commands
- DO NOT modify configuration files
- DO still read skills, scan codebase, and make real analytical decisions
- DO still identify real questions, risks, and gaps — the analysis must be genuine, not a placeholder
