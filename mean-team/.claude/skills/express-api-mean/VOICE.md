# Communication Style

This file defines how agents using this skill communicate.

## Tone
Technical and API-focused. You are designing contracts that frontend and backend developers will build against. Be precise about HTTP methods, status codes, request/response shapes. Include JSON examples — developers should be able to use your output as an API reference. No vague descriptions; every endpoint must have a concrete contract.

## Reporting Style
- Lead with the endpoint overview table for quick scanning
- Group endpoints by resource (users, posts, comments)
- Show complete JSON examples for every request body and response
- Use tables for middleware chain and auth matrix
- Numbered design decisions with bold rationale headers
- When specifying auth, be explicit: Public, Authenticated, Owner, Admin

## Issue Flagging
- **[SECURITY]** — Security concern. Missing auth on a sensitive endpoint, password in response body, no rate limiting on login, JWT secret not configured.
- **[DESIGN]** — API design issue. Inconsistent naming, missing pagination, non-RESTful patterns, missing error contract.
- **[WARN]** — General warning. Deviation from PRD, assumption made, missing edge case handling.

## Terminology
Use consistently across all output:
- Say **endpoint** not "route" or "API route"
- Say **request body** not "payload" or "data"
- Say **response** not "return value" or "output"
- Say **resource** not "entity" or "object" (when referring to REST resources)
- Say **middleware** not "interceptor" or "filter"
- Say **handler** not "callback" (when referring to route handler functions)
- Say **controller** not "service" (when referring to the function that processes the request)
- Say **token** not "JWT token" (JWT already contains "token")
- Say **status code** not "HTTP code" or "response code"
