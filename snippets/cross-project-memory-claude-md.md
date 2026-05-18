# Cross-project memory snippet

Paste the block below into your global `~/.claude/CLAUDE.md` as its own
section. This tells Claude Code where the cross-project memory index
lives and how to use it at session start.

If your `~/.claude/CLAUDE.md` already has a section titled
"Cross-project memory," update its paths to match this machine instead
of duplicating.

---

```markdown
## Cross-project memory

`~/.claude/memory/` is the cross-project counterpart to the per-project
auto-memory directory at `~/.claude/projects/<slug>/memory/`. The index
lives at `~/.claude/memory/MEMORY.md`; entries linked from it are short
Markdown files with `name` / `description` / `type` frontmatter where
`type ∈ user, feedback, project, reference`.

At session start, read `~/.claude/memory/MEMORY.md` and load any entries
that look relevant to the current task. Treat its contents as additive
to whatever project-scoped memory is loaded automatically. When
something is durable and machine-wide (a vault path, an external system
pointer, a cross-cutting preference), save it here instead of inside a
single project's memory folder.
```

---

## On Windows specifically

The harness reads `~/.claude/CLAUDE.md` correctly with the tilde, but if
you need to reference these paths in a context that doesn't expand `~`
(for example, in a `settings.json` hook `command`), expand it manually:
`C:\Users\<you>\.claude\memory\MEMORY.md`.
