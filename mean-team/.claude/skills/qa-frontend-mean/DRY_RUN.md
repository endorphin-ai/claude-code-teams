# Dry-Run Behavior

When `--dry-run` is active, the Frontend QA agent runs FULL analysis but produces a test plan instead of writing tests.

## What to Analyze
- Scan frontend code for all components, pages, hooks, context providers
- Identify what needs testing (every component, every page, every hook, every form)
- Map test scenarios per component (render, interaction, loading, error, empty states)
- Identify API endpoints that need MSW mock handlers
- Estimate test count and coverage goals

## What to Output
- **Test inventory:** Every test suite and test case planned
- **MSW handler plan:** Which API endpoints to mock
- **Test utility plan:** renderWithProviders helper, custom wrappers needed
- **Coverage targets:** Per category (components, pages, hooks, context)
- **Risk areas:** Complex forms, dynamic lists, auth flow, real-time features

## What NOT to Do
- DO NOT write actual test code
- DO NOT create or modify any files
- DO NOT run npm test or install packages
- DO still analyze the frontend code thoroughly
