#!/usr/bin/env bash
# init-skill.sh — Scaffold a full skill directory with playbook structure
#
# Usage: bash .claude/scripts/init-skill.sh <skill-name>
# Example: bash .claude/scripts/init-skill.sh golang-dev
#
# Creates:
#   .claude/skills/<skill-name>/
#   ├── SKILL.md          # Core knowledge + instructions
#   ├── FORMAT.md         # Output format specification
#   ├── VOICE.md          # Communication style guide
#   ├── DRY_RUN.md        # Dry-run analysis instructions
#   ├── scripts/          # Executable code
#   ├── references/       # Patterns, examples, conventions
#   └── workflows/        # Playbooks per task type
#       ├── feature.md    # New feature workflow
#       ├── bugfix.md     # Bug fix workflow
#       └── review.md     # Code review workflow

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: bash .claude/scripts/init-skill.sh <skill-name>"
    echo "Example: bash .claude/scripts/init-skill.sh golang-dev"
    exit 1
fi

SKILL_NAME="$1"
# Convert kebab-case to Title Case for display
SKILL_TITLE=$(echo "$SKILL_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

# Find .claude directory (search up from current dir)
CLAUDE_DIR=""
SEARCH_DIR="$(pwd)"
while [ "$SEARCH_DIR" != "/" ]; do
    if [ -d "$SEARCH_DIR/.claude" ]; then
        CLAUDE_DIR="$SEARCH_DIR/.claude"
        break
    fi
    SEARCH_DIR="$(dirname "$SEARCH_DIR")"
done

if [ -z "$CLAUDE_DIR" ]; then
    echo "Error: .claude directory not found"
    exit 1
fi

SKILL_DIR="$CLAUDE_DIR/skills/$SKILL_NAME"

if [ -d "$SKILL_DIR" ]; then
    echo "Error: Skill directory already exists: $SKILL_DIR"
    exit 1
fi

# Create directory structure
mkdir -p "$SKILL_DIR/scripts"
mkdir -p "$SKILL_DIR/references"
mkdir -p "$SKILL_DIR/workflows"

echo "Created: $SKILL_DIR/"

# --- SKILL.md ---
cat > "$SKILL_DIR/SKILL.md" << SKILLEOF
---
name: $SKILL_NAME
description: "TODO: Describe what this skill provides and when to use it. Be specific about trigger conditions."
---

# $SKILL_TITLE

## Purpose

TODO: What this skill does and why it exists.

## Key Patterns

TODO: Core patterns and conventions for this domain.

See \`references/\` for detailed examples and patterns.

## Conventions

TODO: List domain-specific conventions agents must follow.

## Knowledge Strategy

- **Patterns to capture:** TODO: What patterns should accumulate in references/
- **Examples to collect:** TODO: What successful outputs to save
- **Update permission:** Agents may freely add/update files in \`references/\`. Changes to \`SKILL.md\` or \`scripts/\` require user approval.
SKILLEOF
echo "Created: SKILL.md"

# --- FORMAT.md ---
cat > "$SKILL_DIR/FORMAT.md" << 'FORMATEOF'
# Output Format

This file defines the structured output that agents using this skill MUST produce.
El-capitan and downstream phases parse this output — deviations break the pipeline.

## Required Output Sections

### 1. Summary
TODO: What summary format to produce (1-3 sentences).

### 2. Files Created/Modified
TODO: Table format for file listing.

```markdown
| File | Purpose | Status |
|------|---------|--------|
| path/to/file | What it does | created/modified |
```

### 3. Quality Checklist
TODO: Domain-specific quality checks.

```markdown
- [ ] Check 1
- [ ] Check 2
```

### 4. Issues & Recommendations
TODO: How to report issues found during work.

## Output Example

TODO: Provide a concrete example of complete output.
FORMATEOF
echo "Created: FORMAT.md"

# --- VOICE.md ---
cat > "$SKILL_DIR/VOICE.md" << 'VOICEEOF'
# Communication Style

This file defines how agents using this skill communicate.

## Tone
TODO: Technical level, formality, verbosity. Example: "Terse and technical. No fluff. Code speaks louder than words."

## Reporting Style
TODO: How to structure status updates and reports. Example: "Lead with results, then details. Use tables for file lists. Bullet points for issues."

## Issue Flagging
TODO: How to flag problems. Example: "Prefix critical issues with [CRITICAL]. Use [WARN] for non-blocking concerns. [INFO] for observations."

## Terminology
TODO: Domain-specific terms to use consistently. Example: "Say 'handler' not 'controller'. Say 'repository' not 'DAO'."
VOICEEOF
echo "Created: VOICE.md"

# --- DRY_RUN.md ---
cat > "$SKILL_DIR/DRY_RUN.md" << 'DRYRUNEOF'
# Dry-Run Behavior

When `--dry-run` is active, the agent using this skill executes the FULL analysis
pipeline but produces plans instead of writing files.

## What to Analyze
TODO: What real analysis to perform during dry-run.

Example:
- Read existing codebase structure
- Identify files that would be created/modified
- Analyze dependencies and imports
- Check for conflicts with existing code

## What to Output
TODO: What the dry-run report should contain.

Example:
- File plan: every file to create/modify with path and purpose
- Architecture decisions: choices made and rationale
- Dependencies: packages/libraries required
- Risks: potential issues discovered
- Estimates: scope of changes (files count, complexity)

## What NOT to Do
- DO NOT create, modify, or delete any files
- DO NOT install packages or run build commands
- DO NOT modify configuration files
- DO still read skills, scan codebase, and make real decisions
DRYRUNEOF
echo "Created: DRY_RUN.md"

# --- workflows/feature.md ---
cat > "$SKILL_DIR/workflows/feature.md" << 'FEATUREEOF'
# Workflow: New Feature Implementation

Use this playbook when implementing a new feature from a PRD.

## Steps

1. **Read PRD** — Extract the feature requirements, acceptance criteria, and API contracts.

2. **Analyze Existing Code** — Scan the codebase for relevant files, patterns, and integration points.

3. **Plan Implementation** — List files to create/modify, define the approach, identify dependencies.

4. **Implement** — Write the code following skill patterns and conventions.

5. **Verify** — Run domain-specific verification (build, lint, type-check).

6. **Report** — Output results in FORMAT.md structure. Delegate to el-capitan.

## Checklist
- [ ] All acceptance criteria addressed
- [ ] Follows skill patterns (see references/)
- [ ] Output matches FORMAT.md
- [ ] No files modified outside scope
FEATUREEOF
echo "Created: workflows/feature.md"

# --- workflows/bugfix.md ---
cat > "$SKILL_DIR/workflows/bugfix.md" << 'BUGFIXEOF'
# Workflow: Bug Fix

Use this playbook when fixing a reported bug.

## Steps

1. **Understand the Bug** — Read the bug report, reproduce mentally, identify expected vs actual behavior.

2. **Locate the Root Cause** — Trace the code path, identify the source of the defect.

3. **Fix** — Apply the minimal fix that addresses the root cause without side effects.

4. **Verify** — Confirm the fix resolves the issue. Check for regressions.

5. **Report** — Output results in FORMAT.md structure. Delegate to el-capitan.

## Checklist
- [ ] Root cause identified (not just symptoms)
- [ ] Fix is minimal and targeted
- [ ] No unrelated changes
- [ ] Output matches FORMAT.md
BUGFIXEOF
echo "Created: workflows/bugfix.md"

# --- workflows/review.md ---
cat > "$SKILL_DIR/workflows/review.md" << 'REVIEWEOF'
# Workflow: Code Review

Use this playbook when reviewing code for quality, correctness, and standards.

## Steps

1. **Read the Code** — Scan all files in scope for the review.

2. **Check Standards** — Verify against skill patterns and conventions (see references/).

3. **Identify Issues** — Categorize as: critical (must fix), warning (should fix), info (suggestion).

4. **Report** — Output results in FORMAT.md structure with issue list. Delegate to el-capitan.

## Checklist
- [ ] All files in scope reviewed
- [ ] Issues categorized by severity
- [ ] Actionable recommendations provided
- [ ] Output matches FORMAT.md
REVIEWEOF
echo "Created: workflows/review.md"

echo ""
echo "Skill '$SKILL_NAME' scaffolded at $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Fill in TODOs in SKILL.md (core knowledge)"
echo "  2. Fill in FORMAT.md (output format for agents)"
echo "  3. Fill in VOICE.md (communication style)"
echo "  4. Fill in DRY_RUN.md (dry-run analysis behavior)"
echo "  5. Customize workflows/ playbooks for your domain"
echo "  6. Add reference material to references/"
