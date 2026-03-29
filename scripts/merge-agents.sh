#!/usr/bin/env bash
# merge-agents.sh — installs Claude agents into a target project
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
#       concatenates base + overlay into <TARGET_DIR>/.claude/agents/<agent>.md
#     - Otherwise, copies the base agent as-is

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_DIR="$(dirname "$SCRIPT_DIR")"
STACK="${1:-base}"
TARGET_DIR="${2:-$(pwd)}"
AGENTS_OUT="$TARGET_DIR/.claude/agents"

# Validate stack
if [ "$STACK" != "base" ] && [ ! -d "$PLAYBOOK_DIR/agents/stacks/$STACK" ]; then
  echo "Error: Unknown stack '$STACK'." >&2
  echo "" >&2
  echo "Available stacks:" >&2
  ls "$PLAYBOOK_DIR/agents/stacks/" >&2
  exit 1
fi

mkdir -p "$AGENTS_OUT"

echo "Claude Playbook — installing agents"
echo "  Playbook : $PLAYBOOK_DIR"
echo "  Stack    : $STACK"
echo "  Target   : $AGENTS_OUT"
echo ""

for base_file in "$PLAYBOOK_DIR/agents/base/"*.md; do
  agent_name="$(basename "$base_file")"
  overlay="$PLAYBOOK_DIR/agents/stacks/$STACK/$agent_name"
  out="$AGENTS_OUT/$agent_name"

  if [ "$STACK" != "base" ] && [ -f "$overlay" ]; then
    {
      cat "$base_file"
      printf "\n\n---\n\n"
      cat "$overlay"
    } > "$out"
    echo "  [merged]  $agent_name  ($STACK overlay applied)"
  else
    cp "$base_file" "$out"
    echo "  [base]    $agent_name"
  fi
done

count=$(ls "$AGENTS_OUT"/*.md 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "Done. $count agents installed to $AGENTS_OUT"
