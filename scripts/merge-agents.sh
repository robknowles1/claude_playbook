#!/usr/bin/env bash
# merge-agents.sh — installs Claude agents and skills into a target project
#
# Usage:
#   bash merge-agents.sh [STACK] [TARGET_DIR]
#
# Arguments:
#   STACK       — stack name matching a directory in agents/stacks/ (default: base)
#   TARGET_DIR  — path to the target project (default: current directory)
#
# What it does:
#   For each agent in agents/base/:
#     - If a matching overlay exists in agents/stacks/<STACK>/,
#       merges base + overlay into <TARGET_DIR>/.claude/agents/<agent>/AGENT.md
#     - Otherwise, installs the base agent as-is
#   For every agent installed, also generates a matching skill at
#     <TARGET_DIR>/.claude/skills/<agent>/SKILL.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_DIR="$(dirname "$SCRIPT_DIR")"
STACK="${1:-base}"
TARGET_DIR="${2:-$(pwd)}"
AGENTS_OUT="$TARGET_DIR/.claude/agents"
SKILLS_OUT="$TARGET_DIR/.claude/skills"

# Validate stack
if [ "$STACK" != "base" ] && [ ! -d "$PLAYBOOK_DIR/agents/stacks/$STACK" ]; then
  echo "Error: Unknown stack '$STACK'." >&2
  echo "" >&2
  echo "Available stacks:" >&2
  ls "$PLAYBOOK_DIR/agents/stacks/" >&2
  exit 1
fi

mkdir -p "$AGENTS_OUT"
mkdir -p "$SKILLS_OUT"

echo "Claude Playbook — installing agents + skills"
echo "  Playbook : $PLAYBOOK_DIR"
echo "  Stack    : $STACK"
echo "  Target   : $TARGET_DIR/.claude"
echo ""

for base_file in "$PLAYBOOK_DIR/agents/base/"*.md; do
  agent_name="$(basename "$base_file" .md)"
  overlay="$PLAYBOOK_DIR/agents/stacks/$STACK/$agent_name.md"

  # Extract fields from base frontmatter
  description=$(awk '/^---/{f++; next} f==1 && /^description:/{sub(/^description: */, ""); print; exit}' "$base_file")
  tools_raw=$(awk '/^---/{f++; next} f==1 && /^tools:/{sub(/^tools: */, ""); print; exit}' "$base_file")
  # Convert "Read, Write, Edit" → "Read Write Edit"
  allowed_tools=$(echo "$tools_raw" | sed 's/,//g' | tr -s ' ' | sed 's/^ //;s/ $//')

  # Extract body (everything after the closing --- of frontmatter)
  base_body=$(awk 'BEGIN{count=0} /^---/{count++; next} count>=2{print}' "$base_file")

  # Write agent
  mkdir -p "$AGENTS_OUT/$agent_name"
  if [ "$STACK" != "base" ] && [ -f "$overlay" ]; then
    {
      printf -- "---\n"
      printf "name: %s\n" "$agent_name"
      printf "description: %s\n" "$description"
      printf "model: claude-sonnet-4-6\n"
      printf "allowed-tools: %s\n" "$allowed_tools"
      printf -- "---\n"
      printf "%s\n" "$base_body"
      printf "\n---\n\n"
      cat "$overlay"
    } > "$AGENTS_OUT/$agent_name/AGENT.md"
    echo "  [merged]  $agent_name  ($STACK overlay applied)"
  else
    {
      printf -- "---\n"
      printf "name: %s\n" "$agent_name"
      printf "description: %s\n" "$description"
      printf "model: claude-sonnet-4-6\n"
      printf "allowed-tools: %s\n" "$allowed_tools"
      printf -- "---\n"
      printf "%s\n" "$base_body"
    } > "$AGENTS_OUT/$agent_name/AGENT.md"
    echo "  [base]    $agent_name"
  fi

  # Write skill
  mkdir -p "$SKILLS_OUT/$agent_name"
  {
    printf -- "---\n"
    printf "name: %s\n" "$agent_name"
    printf "description: %s\n" "$description"
    printf "context: fork\n"
    printf "agent: %s\n" "$agent_name"
    printf -- "---\n"
    printf '\n$ARGUMENTS\n'
  } > "$SKILLS_OUT/$agent_name/SKILL.md"

done

agent_count=$(find "$AGENTS_OUT" -name "AGENT.md" | wc -l | tr -d ' ')
skill_count=$(find "$SKILLS_OUT" -name "SKILL.md" | wc -l | tr -d ' ')
echo ""
echo "Done. $agent_count agents and $skill_count skills installed to $TARGET_DIR/.claude"
