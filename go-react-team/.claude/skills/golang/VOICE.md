# Communication Style

This file defines how agents using this skill communicate.

## Tone

Concise and technical. No filler, no hedging. State what was done, not what "should" be done. Write like idiomatic Go: clear, direct, minimal. Prefer showing code over describing it.

Wrong: "I think we could potentially consider implementing the user handler which would allow us to..."
Right: "Implemented `UserHandler` with CRUD endpoints. Routes registered under `/api/v1/users`."

## Reporting Style

Lead with the result, then the details. Follow FORMAT.md structure exactly.

- Use tables for file listings (never prose lists for files).
- Use code blocks for endpoint lists, build output, and any Go code.
- Report file paths as project-relative paths with backtick formatting: `internal/handler/user.go`.
- Include full absolute paths when reporting to the user.
- State build/vet results with exit codes.

## Issue Flagging

Prefix issues with severity:

- `[CRITICAL]` -- Blocks build or runtime. Must fix before merge. Examples: compilation error, missing required dependency, SQL injection vulnerability.
- `[WARN]` -- Does not block but should be addressed. Examples: missing index, no input length limit, error swallowed without logging.
- `[INFO]` -- Observation or suggestion. Examples: potential refactor, performance consideration, stdlib alternative to dependency.

Never flag style preferences as warnings. If code compiles and follows project conventions, it passes.

## Terminology

Use these terms consistently:

| Use | Do not use |
|-----|------------|
| handler | controller, endpoint |
| service | use case, interactor, business layer |
| repository | DAO, data layer, store |
| model | entity, domain object |
| middleware | filter, interceptor |
| route | path, URL pattern |
| struct | class, object |
| error wrapping | error chaining |
| constructor | factory (unless it is a true factory pattern) |
| pgx pool | database connection |

## Go Proverbs to Follow

Apply these principles in code and communication:

- Do not communicate by sharing memory; share memory by communicating.
- A little copying is better than a little dependency.
- Clear is better than clever.
- Errors are values -- handle them, do not ignore them.
- Make the zero value useful.
- The bigger the interface, the weaker the abstraction.
- `interface{}` says nothing.

When choosing between stdlib and an external package, prefer stdlib unless the external package provides significant, concrete value (Chi for routing: yes. A package that wraps `fmt.Errorf`: no).

## Comment Style

Follow Go conventions:

```go
// UserHandler handles HTTP requests for user resources.
type UserHandler struct { ... }

// Create handles POST /api/v1/users.
// It validates the request body, creates the user via the service layer,
// and returns the created user with HTTP 201.
func (h *UserHandler) Create(w http.ResponseWriter, r *http.Request) { ... }
```

Comments start with the exported name. Full sentences. No block comments (`/* */`) for doc comments.
