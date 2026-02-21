# Workflow: Bug Fix Regression Testing

Use this playbook when a bug is reported in React frontend code. The goal: write a regression test that **proves the bug exists**, then verify the fix makes it pass.

## Prerequisites

- Bug report with reproduction steps, expected behavior, and actual behavior
- Access to the component/hook/page source code where the bug lives

## Steps

### 1. Understand the Bug

- Read the bug report thoroughly.
- Identify the **user-visible symptom**: what does the user see/experience that is wrong?
- Identify the **expected behavior**: what should the user see/experience instead?
- Map the symptom to a specific component, hook, or page in the codebase.
- Read the source code of the affected file(s) to understand the code path.

**Output:** Bug location (file + component/hook), user-visible symptom, expected behavior.

### 2. Write the Regression Test (RED)

Write a test that **reproduces the bug** — this test MUST FAIL before the fix is applied.

- Create the test in the existing test file for the component/hook, or create a new test file if none exists.
- Name the test after the user-visible behavior, referencing the bug: `"user sees correct total after removing an item (regression: #123)"`
- The test should simulate the exact user actions from the reproduction steps.
- Assert on the expected (correct) behavior — this assertion will fail because the bug is still present.

```typescript
it('user sees updated total after removing item from cart (regression: #456)', async () => {
  const user = userEvent.setup();

  // Arrange: render cart with two items
  render(<CartPage />);
  await waitForElementToBeRemoved(() => screen.queryByText(/loading/i));

  // Act: remove one item
  const removeButtons = screen.getAllByRole('button', { name: /remove/i });
  await user.click(removeButtons[0]);

  // Assert: total should update (this FAILS before fix)
  expect(screen.getByText(/total: \$50\.00/i)).toBeInTheDocument();
});
```

**Run the test:** `npx vitest run --reporter=verbose <test-file>`

- Confirm the test **FAILS** with the bug still present.
- If the test passes, the test is not correctly reproducing the bug — rewrite it.

**Output:** Regression test written, confirmed failing.

### 3. Add MSW Handlers If Needed

If the bug involves API interactions:
- Add or modify MSW handlers to reproduce the exact API response that triggers the bug.
- Test both the buggy scenario and the expected correct scenario.

```typescript
// Handler that reproduces the bug condition
server.use(
  http.delete('/api/v1/cart/items/:id', () => {
    return HttpResponse.json({ success: true, newTotal: 5000 }); // cents
  }),
);
```

**Output:** MSW handlers created/modified if applicable.

### 4. Verify the Fix (GREEN)

After the bug fix is applied (by the developer or the frontend-react agent):

- Run the regression test again: `npx vitest run --reporter=verbose <test-file>`
- Confirm the test **PASSES** with the fix in place.
- If the test still fails, the fix is incomplete — report back with details.

**Output:** Regression test confirmed passing after fix.

### 5. Check for Regressions

Run the full test suite to make sure the fix didn't break anything else:

```bash
npx vitest run --coverage
```

- All previously passing tests must still pass.
- If any test breaks, report it immediately — the fix introduced a regression.
- Check that coverage didn't decrease.

**Output:** Full suite results, any regressions found.

### 6. Report Results

Produce output in FORMAT.md structure:

```
## Summary
Wrote 1 regression test for bug #456 (cart total not updating after item removal).
Test confirmed failing before fix, passing after fix. Full suite: 47 pass, 0 fail.

## Test Files Modified

| File | Tests Added | Status |
|------|-------------|--------|
| `src/pages/CartPage.test.tsx` | 1 (regression) | modified |

## Test Results

Total: 47 | Passed: 47 | Failed: 0 | Skipped: 0

## Regression Test Detail

Test:     "user sees updated total after removing item from cart (regression: #456)"
Before fix: FAIL (total showed $100.00 instead of $50.00)
After fix:  PASS

## Issues & Recommendations

[INFO] Consider adding test for removing the last item from cart (edge case)
```

Delegate to el-capitan via `/invoke-el-capitan`.

## Checklist

- [ ] Bug reproduction steps understood
- [ ] Regression test written with user-centric name referencing bug ID
- [ ] Test confirmed FAILING before fix (red)
- [ ] Test confirmed PASSING after fix (green)
- [ ] Full test suite still passes (no new regressions)
- [ ] Coverage did not decrease
- [ ] Output matches FORMAT.md structure
