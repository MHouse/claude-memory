#!/usr/bin/env bash
# Bootstrap the Claude Code cross-project memory system on this machine.
#
# Idempotent setup:
#   1. Creates ~/.claude/memory/ if absent.
#   2. Seeds ~/.claude/memory/MEMORY.md from MEMORY.md.template if absent.
#   3. Creates ~/.claude/CLAUDE.md with a minimal header if absent.
#   4. Appends the Cross-project memory section to ~/.claude/CLAUDE.md if
#      (and only if) the section isn't already present.
#
# Re-running is a no-op once the system is in place: nothing is
# duplicated, nothing already on disk is overwritten.
#
# Run from a clone of MHouse/claude-memory:
#
#   ./bootstrap.sh

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_home="${HOME}/.claude"
memory_dir="${claude_home}/memory"
memory_index="${memory_dir}/MEMORY.md"
claude_md="${claude_home}/CLAUDE.md"
template="${repo_root}/MEMORY.md.template"
snippet="${repo_root}/snippets/cross-project-memory-claude-md.md"

[ -f "$template" ] || { echo "Template not found at $template -- run this script from a clone of MHouse/claude-memory." >&2; exit 1; }
[ -f "$snippet"  ] || { echo "Snippet not found at $snippet -- run this script from a clone of MHouse/claude-memory." >&2; exit 1; }

summary=()

# 1. Memory directory
if [ ! -d "$memory_dir" ]; then
    mkdir -p "$memory_dir"
    summary+=("  created   $memory_dir")
else
    summary+=("  exists    $memory_dir")
fi

# 2. MEMORY.md index
if [ ! -f "$memory_index" ]; then
    cp "$template" "$memory_index"
    summary+=("  created   $memory_index (from template)")
else
    summary+=("  exists    $memory_index (left untouched)")
fi

# 3 + 4. CLAUDE.md + section
section_marker="## Cross-project memory"
needs_append=0

if [ ! -f "$claude_md" ]; then
    cat > "$claude_md" <<'EOF'
# Global CLAUDE.md

Personal preferences and conventions that apply across all projects.
Project-specific guidance lives in each repo's CLAUDE.md.

EOF
    summary+=("  created   $claude_md (with minimal header)")
    needs_append=1
elif grep -qF "$section_marker" "$claude_md"; then
    summary+=("  exists    $claude_md (section already present, skipping)")
else
    summary+=("  exists    $claude_md (section missing, appending)")
    needs_append=1
fi

if [ "$needs_append" -eq 1 ]; then
    # Ensure file ends with newline before appending
    if [ -s "$claude_md" ]; then
        last_char="$(tail -c 1 "$claude_md")"
        [ -n "$last_char" ] && printf '\n' >> "$claude_md"
    fi
    # Add blank-line separator before our new section
    printf '\n' >> "$claude_md"
    cat "$snippet" >> "$claude_md"
    # Ensure trailing newline
    last_char="$(tail -c 1 "$claude_md")"
    [ -n "$last_char" ] && printf '\n' >> "$claude_md"
    summary+=("  appended  cross-project memory section to $claude_md")
fi

echo ""
echo "Bootstrap complete."
echo ""
echo "Summary:"
for item in "${summary[@]}"; do
    echo "$item"
done
echo ""
echo "Next steps:"
echo "  - Open ~/.claude/CLAUDE.md and confirm the new section reads well."
echo "  - Optionally seed ~/.claude/memory/user_identity.md (see BOOTSTRAP.md step 4)."
echo "  - Save memories as you work; the system fills itself."
