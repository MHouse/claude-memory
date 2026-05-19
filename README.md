# claude-memory

A small, user-agnostic memory system for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).
Sets up a two-layer Markdown memory store that future Claude Code sessions
read at session start — so durable knowledge (preferences, tools, recurring
gotchas, project facts) survives across conversations and across projects.

This repo ships the **scaffold**, not anyone's content. Bootstrap a fresh
empty system on any machine and let it accrue naturally.

## Why this exists

Claude Code has built-in mechanisms for in-conversation context, and the
harness can load per-project memory automatically — but there is no built-in
home for *cross-project* durable knowledge ("here's my vault path", "this
tool has a subtle gotcha I hit twice", "I prefer commits formatted like
X"). This repo defines a simple convention for that layer and a five-minute
bootstrap to set it up.

## The two layers

1. **Cross-project memory** — `~/.claude/memory/`. Applies to every project
   on this machine. Index file is `MEMORY.md`. **This repo bootstraps this
   layer.**
2. **Per-project auto-memory** — `~/.claude/projects/<slug>/memory/`. The
   harness creates and manages this dir per project automatically; you
   don't bootstrap it. Same file format and frontmatter conventions as the
   cross-project layer.

The slug under `projects/` is derived from the working-directory path; you
don't pick it.

## File format

Each memory is a short Markdown file with YAML frontmatter:

```yaml
---
name: Short title shown in the index
description: One-line summary of when and why this matters
type: user | feedback | project | reference
---

Body content — what to remember, when to apply it, paths or links if useful.
Keep it concise; this gets read into context every relevant session.
```

The four types:

- **`user`** — identity, persistent personal preferences (email aliases,
  default account when ambiguous, etc.).
- **`feedback`** — "next time, do X instead of Y" lessons captured from
  prior sessions; behavior corrections.
- **`project`** — durable facts about a specific product or codebase
  (planned features, TODOs that aren't yet scoped, owner notes).
- **`reference`** — pointers to external systems Claude should know about
  (vault paths, runbooks, tool quirks, CLI argument gotchas).

The top-level `MEMORY.md` is the index — a list of one-line links to the
individual files, ordered however you find useful.

## Quick start

```bash
git clone https://github.com/MHouse/claude-memory.git
cd claude-memory
./bootstrap.sh        # macOS / Linux
# or
.\bootstrap.ps1       # Windows
```

The script is idempotent — it creates `~/.claude/memory/`, seeds an empty
`MEMORY.md` from the template, ensures `~/.claude/CLAUDE.md` exists, and
appends the cross-project memory section if it isn't already there.
Re-running is a no-op once the system is in place; existing customisations
in `CLAUDE.md` are preserved.

For the manual recipe, see [BOOTSTRAP.md](BOOTSTRAP.md).

## Maintenance

Run the [`anthropic-skills:consolidate-memory`](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
skill (also available as `/consolidate-memory`) periodically to merge
duplicates, prune stale facts, fix orphan links, and surface promotion
candidates. No-op on a small memory set — useful after ~10+ entries or a
few months of accumulation, whichever comes first.

## What this repo deliberately does *not* do

- **Ship anyone's actual memories.** Memories are personal and
  machine-local; this repo only carries the scaffold.
- **Sync memories across machines.** Each install accrues its own
  entries. If you want shared content, save it via another mechanism
  (your dotfiles, a shared note, etc.) — not this repo.
- **Define a "right" memory taxonomy.** The four types above are a
  starting point. The template hints at sub-organisation
  (`tools/{name}.md`, `domain/{topic}/`, `general.md`) but you're
  encouraged to grow whatever taxonomy fits your work.

## License

MIT — see [LICENSE](LICENSE).
