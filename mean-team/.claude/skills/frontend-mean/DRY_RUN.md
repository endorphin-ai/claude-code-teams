# Dry-Run Behavior

When `--dry-run` is active, the Frontend Dev agent runs FULL analysis but produces a plan instead of writing code.

## What to Analyze
- Read React architecture design from previous phase
- Map each page to its components and API calls
- Identify all npm packages needed
- Plan the file structure
- Check for missing pieces (loading states, error handling, responsive breakpoints)

## What to Output
- **File plan:** Every file to create with path and purpose
- **Dependency list:** npm packages needed with versions
- **Implementation order:** Which files to create first (services, then hooks, then context, then common components, then layout, then features, then pages, then App, then routing)
- **API integration map:** Which components call which endpoints
- **Risk flags:** Complex forms, real-time features, large lists needing virtualization

## What NOT to Do
- DO NOT write actual component code
- DO NOT create, modify, or delete any files
- DO NOT run npm install or any build commands
- DO still analyze the architecture design thoroughly
