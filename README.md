# Claude Playbook

A global, stack-composable Claude Code agent library. Install specialized agents (PM, Developer, Reviewer, QA, Architect, DevOps, Scribe, Security) into any project with a single `make` command.

## How It Works

Agents are organized in two layers:

1. **Base agents** (`agents/base/`) — stack-agnostic role definitions. Work in any project.
2. **Stack overlays** (`agents/stacks/<stack>/`) — additive sections appended to the base at install time, adding stack-specific commands, patterns, and conventions.

When you run `make -f .../Makefile init STACK=rails` from a target project, the script merges each base agent with its matching overlay (if one exists) and writes the results to `.claude/agents/` in that project. Agents with no overlay are installed as-is.

## Prerequisites

- `bash` (macOS ships with it)
- `make` (macOS ships with it via Xcode Command Line Tools — run `xcode-select --install` if missing)

## Quickstart

### 1. Get this repo (once)

This repo lives at `~/repos/claude_playbook`. If you push it to GitHub in future, clone it to that path on each machine:

```bash
git clone git@github.com:robknowles1/claude_playbook.git ~/repos/claude_playbook
```

### 2. Add a shell alias (recommended)

```bash
# ~/.zshrc or ~/.bashrc
# Update the path if you cloned the repo somewhere other than ~/repos/claude_playbook
alias claude-init='make -f ~/repos/claude_playbook/Makefile init'
```

### 3. Initialize a project

From the root of any project:

```bash
# Rails project
claude-init STACK=rails

# React project
claude-init STACK=react

# Base agents only (no stack assumptions)
claude-init
```

This creates `.claude/agents/<name>/AGENT.md` and `.claude/skills/<name>/SKILL.md` in the target project. Claude Code automatically loads agents and skills from those directories.

### 4. Copy the CLAUDE.md template

```bash
cp ~/repos/claude_playbook/templates/CLAUDE.md ./CLAUDE.md
```

Then fill in the project-specific sections.

### 5. Update agents (pull latest from playbook)

```bash
claude-init STACK=rails   # re-run any time to pick up playbook changes
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `init` | Install agents into the current directory (or `TARGET=`) for `STACK=` |
| `update` | Alias for `init` — re-runs the merge to pick up latest changes |
| `list-stacks` | Show available stacks |
| `help` | Show usage |

All targets accept:
- `STACK=<name>` — stack to use (default: `base`)
- `TARGET=<path>` — target project directory (default: current directory)

## Agents

| Agent | Role | Does NOT do |
|-------|------|-------------|
| `pm` | Translates requirements into structured specs in `docs/specs/` | Write code |
| `developer` | Implements features from specs, writes tests | Write specs, deploy |
| `reviewer` | Reviews code for correctness, security, conventions | Write code |
| `qa` | Runs tests, verifies AC coverage, produces pass/fail report | Write code |
| `architect` | System design, ADRs, technical guidance | Write code |
| `devops` | CI/CD, deployment, environment configuration | Write app logic |
| `scribe` | README, changelogs, ADR indexes, release notes | Write code |
| `security` | Security audits, threat modeling, dependency scans | Write code |

## Recommended Workflow

```
pm → architect (if complex) → developer → reviewer → qa
                                    ↑_______________|
                                    (fix and re-review)
```

1. **PM** — take a raw requirement, produce a spec in `docs/specs/`
2. **Architect** — for complex features, review spec and add technical guidance / ADR
3. **Developer** — implement the spec, write tests, update spec status
4. **Reviewer** — review code against spec; approve or request changes
5. **QA** — run tests and scans, verify AC coverage, sign off

DevOps, Scribe, and Security are invoked as needed alongside this flow.

## Available Stacks

| Stack | Overlays provided for |
|-------|-----------------------|
| `rails` | developer, reviewer, qa, devops |
| `react` | developer, reviewer, qa |

## Adding a New Agent

1. Create `agents/base/<agent-name>.md` with the standard frontmatter (`name`, `description`, `tools`) and role content.
2. Add stack overlays in `agents/stacks/<stack>/<agent-name>.md` for any stacks where the agent needs stack-specific content. Overlays are pure markdown, no frontmatter.
3. Add a corresponding entry to the **Agents** table in this README.

The merge script automatically generates both the `.claude/agents/<name>/AGENT.md` and `.claude/skills/<name>/SKILL.md` for every agent it installs. **Every agent must have a matching skill** — this is handled automatically at install time; no extra step required.

## Adding a New Stack

1. Create `agents/stacks/<your-stack>/` directory.
2. Add overlay files for any agents you want to extend. Filename must match the base agent (e.g. `developer.md`).
3. Overlay files are **pure markdown, no frontmatter** — they are appended after the base content with a horizontal rule separator.
4. Add the stack to the **Available Stacks** table in this README.

The merge script picks up the new stack automatically. Skills are generated for every agent in the stack — no extra step required.

## Project Structure

```
claude_playbook/
├── README.md
├── Makefile                          ← invoke from any project
├── scripts/
│   └── merge-agents.sh              ← merges base + overlay, writes agents + skills
├── agents/
│   ├── base/                        ← 8 stack-agnostic agent source files
│   │   ├── architect.md
│   │   ├── developer.md
│   │   ├── devops.md
│   │   ├── pm.md
│   │   ├── qa.md
│   │   ├── reviewer.md
│   │   ├── scribe.md
│   │   └── security.md
│   └── stacks/
│       ├── rails/                   ← Rails 8 / ERB / Tailwind / Hotwire overlays
│       │   ├── developer.md
│       │   ├── devops.md
│       │   ├── qa.md
│       │   └── reviewer.md
│       └── react/                   ← React / TypeScript / Tailwind overlays
│           ├── developer.md
│           ├── qa.md
│           └── reviewer.md
└── templates/
    └── CLAUDE.md                    ← copy this into new projects and fill it in
```

### What gets installed into target projects

`make init` writes the following structure into `<TARGET>/.claude/`:

```
.claude/
├── agents/
│   ├── developer/
│   │   └── AGENT.md                ← merged base + stack content
│   ├── reviewer/
│   │   └── AGENT.md
│   └── ...                         ← one directory per agent
└── skills/
    ├── developer/
    │   └── SKILL.md                ← auto-generated, invokes the matching agent
    ├── reviewer/
    │   └── SKILL.md
    └── ...                         ← one directory per agent
```
