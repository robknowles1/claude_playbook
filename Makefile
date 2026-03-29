# Claude Playbook — Makefile
#
# Install Claude agents into any project with a single command.
#
# Usage (from any project directory):
#   make -f ~/repos/claude_playbook/Makefile init STACK=rails
#   make -f ~/repos/claude_playbook/Makefile init STACK=react
#   make -f ~/repos/claude_playbook/Makefile init           # base agents only
#
# Optional override:
#   make -f ~/repos/claude_playbook/Makefile init STACK=rails TARGET=/path/to/project

PLAYBOOK_DIR := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
TARGET       ?= $(CURDIR)
STACK        ?= base

.PHONY: init update list-stacks help

## Install agents into TARGET for the given STACK (creates .claude/agents/ in TARGET)
init:
	@bash "$(PLAYBOOK_DIR)/scripts/merge-agents.sh" "$(STACK)" "$(TARGET)"

## Re-run init to pull the latest playbook changes into an existing project
update: init

## List all available stacks
list-stacks:
	@echo "Available stacks:"
	@ls "$(PLAYBOOK_DIR)/agents/stacks/"

## Show usage
help:
	@echo ""
	@echo "Usage:"
	@echo "  make -f $(PLAYBOOK_DIR)/Makefile init [STACK=<stack>] [TARGET=<path>]"
	@echo "  make -f $(PLAYBOOK_DIR)/Makefile update [STACK=<stack>] [TARGET=<path>]"
	@echo "  make -f $(PLAYBOOK_DIR)/Makefile list-stacks"
	@echo ""
	@echo "Defaults: STACK=base, TARGET=current directory"
	@echo ""
