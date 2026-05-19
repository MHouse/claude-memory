## Cross-project memory

<!-- Section managed by the claude-memory bootstrap (re-run with -Force / --force to resync). -->

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
