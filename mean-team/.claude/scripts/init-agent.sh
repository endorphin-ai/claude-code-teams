#!/usr/bin/env bash
# init-agent.sh — Scaffold an agent by reading AGENT_TEMPLATE.md and replacing placeholders
#
# Usage: bash .claude/scripts/init-agent.sh <agent-name> <skill-name> [model] [color]
# Example: bash .claude/scripts/init-agent.sh go-dev golang-dev sonnet green
#
# Reads AGENT_TEMPLATE.md at runtime — single source of truth.
# Only replaces 5 structural placeholders, leaves all other {…} as TODOs.
#
# Creates:
#   .claude/agents/<agent-name>.md         # Agent definition from template
#   .claude/agent-memory/<agent-name>/
#   └── MEMORY.md                           # Empty memory file

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: bash .claude/scripts/init-agent.sh <agent-name> <skill-name> [model] [color]"
    echo ""
    echo "Arguments:"
    echo "  agent-name   Kebab-case agent name (e.g., go-dev)"
    echo "  skill-name   Skill this agent uses (e.g., golang-dev)"
    echo "  model        haiku | sonnet | opus (default: sonnet)"
    echo "  color        blue | green | yellow | red | purple | cyan (default: blue)"
    echo ""
    echo "Example: bash .claude/scripts/init-agent.sh go-dev golang-dev sonnet green"
    exit 1
fi

AGENT_NAME="$1"
SKILL_NAME="$2"
MODEL="${3:-sonnet}"
COLOR="${4:-blue}"

# Convert kebab-case to Title Case
AGENT_TITLE=$(echo "$AGENT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

# Find .claude directory
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

TEMPLATE_FILE="$CLAUDE_DIR/agents/AGENT_TEMPLATE.md"
AGENT_FILE="$CLAUDE_DIR/agents/$AGENT_NAME.md"
MEMORY_DIR="$CLAUDE_DIR/agent-memory/$AGENT_NAME"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: AGENT_TEMPLATE.md not found: $TEMPLATE_FILE"
    exit 1
fi

if [ -f "$AGENT_FILE" ]; then
    echo "Error: Agent already exists: $AGENT_FILE"
    exit 1
fi

# Verify skill exists
if [ ! -d "$CLAUDE_DIR/skills/$SKILL_NAME" ]; then
    echo "Warning: Skill directory not found: $CLAUDE_DIR/skills/$SKILL_NAME"
    echo "Run init-skill.sh first: bash .claude/scripts/init-skill.sh $SKILL_NAME"
    echo "Continuing anyway..."
fi

# Create agent-memory directory
mkdir -p "$MEMORY_DIR"
cat > "$MEMORY_DIR/MEMORY.md" << 'MEMEOF'
# Agent Memory

This file is empty. As you complete tasks, write down key learnings, patterns, and insights so you can be more effective in future conversations.
MEMEOF
echo "Created: $MEMORY_DIR/MEMORY.md"

# Read AGENT_TEMPLATE.md and replace only the 5 structural placeholders.
# All other {…} patterns (TODOs, descriptions) are left for the Architect to fill in.
sed \
    -e "s/{agent-name}/$AGENT_NAME/g" \
    -e "s/{skill-name}/$SKILL_NAME/g" \
    -e "s/{Title}/$AGENT_TITLE/g" \
    -e "s/{haiku | sonnet | opus}/$MODEL/" \
    -e "s/{blue | green | yellow | red | purple | cyan}/$COLOR/" \
    "$TEMPLATE_FILE" > "$AGENT_FILE"

echo "Created: $AGENT_FILE"
echo ""
echo "Agent '$AGENT_NAME' scaffolded successfully"
echo "  Agent file:  $AGENT_FILE"
echo "  Skill:       $SKILL_NAME"
echo "  Model:       $MODEL"
echo "  Memory:      $MEMORY_DIR/"
echo "  Template:    $TEMPLATE_FILE (read at runtime)"
echo ""
echo "Next steps:"
echo "  1. Fill in TODOs in the agent file"
echo "  2. Customize Identity, Operating Modes, Instructions"
echo "  3. Define domain-specific tasks in Task Tracking"
echo "  4. Add Quality Standards for your domain"
