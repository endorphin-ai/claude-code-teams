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
