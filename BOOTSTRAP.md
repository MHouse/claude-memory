# Bootstrap the cross-project memory layer

Five-minute setup. Run once per machine.

> Memories don't sync across machines. This repo ships only the scaffold —
> existing entries on another machine stay there; this machine's
> `~/.claude/memory/` starts empty and fills as you work.

## 1. Create the memory directory

Resolve the absolute path of `~/.claude/memory/` for this machine (it's
under `$HOME` on macOS/Linux, `$env:USERPROFILE` on Windows). Create it
if it doesn't exist.

```bash
# macOS / Linux
mkdir -p ~/.claude/memory
```

```powershell
# Windows PowerShell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\memory" | Out-Null
```

## 2. Seed `MEMORY.md` from the template

Copy [`MEMORY.md.template`](MEMORY.md.template) into the directory as
`MEMORY.md`. Don't add entries yet — leave the **Entries** heading empty.

```bash
# macOS / Linux (from a clone of this repo)
cp MEMORY.md.template ~/.claude/memory/MEMORY.md
```

```powershell
# Windows PowerShell (from a clone of this repo)
Copy-Item MEMORY.md.template "$env:USERPROFILE\.claude\memory\MEMORY.md"
```

## 3. Tell Claude Code to read the index at session start

Open (or create) the **global** `~/.claude/CLAUDE.md`. Add the snippet
from [`snippets/cross-project-memory-claude-md.md`](snippets/cross-project-memory-claude-md.md)
as a section. This is what tells future Claude Code sessions to load the
index when they boot.

If a "Cross-project memory" section already exists, update its paths to
match this machine — don't duplicate.

## 4. Optionally seed `user_identity.md`

Skip unless you want to. If you'd rather have your name/email pre-loaded
into every session, create one entry:

```markdown
---
name: User identity and email addresses
description: Default name + email for git config, commit trailers, etc.
type: user
---

- Name: <Your Name>
- Default email: <you@example.com>
- Other addresses (when ambiguous, default to the one above):
  - work: <you@work.example.com>
  - personal: <you@personal.example>
```

Save as `~/.claude/memory/user_identity.md` and add a line to
`~/.claude/memory/MEMORY.md` under **Entries** linking to it. That's the
only seed worth doing during bootstrap; everything else accrues
naturally.

## 5. Verify

- `~/.claude/memory/MEMORY.md` exists with the taxonomy header and an
  empty `## Entries` section.
- `~/.claude/CLAUDE.md` contains the cross-project memory section
  pointing at the file above.
- Memory-load verification exercises itself naturally once entries
  accrue — the index is intentionally empty at this point, so there's
  nothing to recall yet. The first real session that saves a memory
  and reads it back later is the smoke test.

That's it. Save memories as you work — by hand, or by asking Claude to
save them — and the system fills itself.

## Maintenance (later, not now)

Run the `anthropic-skills:consolidate-memory` skill periodically once
the memory set passes ~10 entries or a few months of accumulation,
whichever comes first. No-op before that.
