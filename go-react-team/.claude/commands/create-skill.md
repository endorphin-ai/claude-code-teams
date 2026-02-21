# /create-skill

Create a new skill using scaffold + skill-creator guidance.

## Context

$ARGUMENTS

## Instructions

### Parse Arguments

Expected format: `/create-skill [name] [description]`

- **name**: kebab-case skill name (e.g., `golang-dev`, `react-dev`, `qa-testing`)
- **description**: (optional) one-line purpose

If the name is missing, ask interactively.

### Process

#### Step 1: Scaffold

Run the scaffold script to create the skill directory with all required files:

```bash
bash .claude/scripts/init-skill.sh {skill-name}
```

This creates:
```
.claude/skills/{skill-name}/
├── SKILL.md           # Core knowledge + domain patterns
├── FORMAT.md          # Output format specification
├── VOICE.md           # Communication style guide
├── DRY_RUN.md         # Dry-run analysis instructions
├── scripts/           # Executable code for deterministic operations
├── references/        # Patterns, examples, conventions
└── workflows/         # Playbooks per task type
    ├── feature.md
    ├── bugfix.md
    └── review.md
```

#### Step 2: Fill with real content

Read `.claude/skills/skill-creator/SKILL.md` for guidance on writing effective skill content. Follow its process:

1. **Understand** — Ask the user what this skill does, what triggers it, concrete usage examples
2. **Plan** — Identify what scripts, references, and domain knowledge to include
3. **Edit** — Fill the scaffolded files with real domain knowledge:
   - **SKILL.md** — Core patterns, conventions, domain expertise. Keep concise (<500 lines). Use progressive disclosure: reference files in `references/` for detailed content.
   - **FORMAT.md** — Define the structured output agents using this skill must produce (sections, tables, checklists)
   - **VOICE.md** — Communication style: tone, terminology, how to flag issues, report structure
   - **DRY_RUN.md** — What analysis to perform in dry-run mode, what plan output to produce
   - **workflows/** — Step-by-step playbooks for feature development, bug fixes, reviews
   - **references/** — Accumulated patterns, proven approaches, examples
4. **Iterate** — Test the skill on real tasks, refine based on results

### Key Reminders

- The `description` field in SKILL.md frontmatter is the primary trigger mechanism — be specific about when to use this skill
- Keep SKILL.md body under 500 lines. Move detailed content to `references/`
- Every agent that uses this skill expects FORMAT.md, VOICE.md, DRY_RUN.md, and workflows/ to exist
