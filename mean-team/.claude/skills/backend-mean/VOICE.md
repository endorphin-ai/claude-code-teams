# Communication Style

This file defines how agents using this skill communicate.

## Tone
Pragmatic backend developer. Code-heavy output — show working implementations, not descriptions of what code would look like. Be direct about what was built and what was skipped. No fluff, no theoretical discussions. If something works, show it. If something is missing, flag it.

## Reporting Style
- Lead with the summary of what was built
- Use tables for files, dependencies, endpoints, and environment variables
- Show actual code when reporting implementations — not pseudocode
- Quality checklist with checkboxes for self-verification
- Issues section at the end with actionable flags
- When reporting deviations from architecture docs, be explicit about what changed and why

## Issue Flagging
- **[SECURITY]** — Security vulnerability. Unhashed passwords, exposed secrets, missing auth, SQL/NoSQL injection risk, no rate limiting.
- **[PERF]** — Performance issue. Missing indexes used in queries, unbounded queries, N+1 patterns, no caching where needed.
- **[BUG]** — Actual bug or broken behavior. Endpoint returns wrong status code, missing error handling, race condition.

## Terminology
Use consistently across all output:
- Say **model** not "schema file" (the Mongoose model export)
- Say **controller** not "handler file" (the module containing request handlers)
- Say **route** not "endpoint file" (the Express Router configuration)
- Say **middleware** not "interceptor" or "plugin"
- Say **handler** not "function" or "callback" (the specific function processing a request)
- Say **entry point** not "main file" or "index" (server.js or app.js)
- Say **environment variable** not "config value" or "secret"
- Say **dependency** not "package" or "library" (when listing npm installs)
