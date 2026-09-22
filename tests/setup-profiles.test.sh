#!/usr/bin/env bash
set -u

pass() {
  printf 'PASS %s\n' "$1"
}

fail() {
  printf 'FAIL %s: %s\n' "$1" "$2" >&2
  exit 1
}

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ORIG_HOME="$HOME"
SCRATCH="$(mktemp -d)"
export HOME="$SCRATCH/home"
mkdir -p "$HOME"
export DOTFILES_SKIP_INSTALL=1 DOTFILES_DIR
export WORK_AGENTS_DIR="$HOME/.work-agents"
trap 'rm -rf "$SCRATCH"' EXIT

SETUP="$DOTFILES_DIR/setup.sh"
RUN_OUT=""
RUN_ERR=""
RUN_RC=0

run_setup() {
  local name="$1"
  shift
  RUN_OUT="$SCRATCH/$name.out"
  RUN_ERR="$SCRATCH/$name.err"
  set +e
  "$SETUP" "$@" >"$RUN_OUT" 2>"$RUN_ERR"
  RUN_RC=$?
}

links_into_work_agents() {
  find "$HOME" -type l -print | while IFS= read -r link; do
    local target
    target="$(readlink "$link" 2>/dev/null)"
    case "$target" in
      *".work-agents"*) printf '%s\n' "$link" ;;
    esac
  done
}

tracked_home_references() {
  local root="$1"
  local scope="$2"
  local home_parent
  local needle
  local relative
  home_parent="$(dirname "$ORIG_HOME")"
  needle="$home_parent/"

  git -C "$root" ls-files -z | while IFS= read -r -d '' relative; do
    case "$relative" in
      .git | .git/* | *.vsix | agents/guidelines/karpathy | agents/guidelines/karpathy/*)
        continue
        ;;
    esac
    if [ "$scope" = "work" ] && [ "$relative" = "todo/opencode-setup.md" ]; then
      continue
    fi
    [ -f "$root/$relative" ] || continue
    if grep -qF "$needle" "$root/$relative"; then
      printf '%s\n' "$relative"
    fi
  done
}

plant_fixture() {
  mkdir -p \
    "$WORK_AGENTS_DIR/agents/rules" \
    "$WORK_AGENTS_DIR/agents/skills/fx-skill" \
    "$WORK_AGENTS_DIR/agents/skills/fx-mcp" \
    "$WORK_AGENTS_DIR/agents/repos/fxrepo" \
    "$WORK_AGENTS_DIR/planning" \
    "$WORK_AGENTS_DIR/todo"

  printf '%s\n' '# Later rules fixture' > "$WORK_AGENTS_DIR/agents/rules/50-later.md"
  cat > "$WORK_AGENTS_DIR/agents/skills/fx-skill/SKILL.md" <<'EOF'
---
name: fx-skill
description: fixture
---
EOF
  cat > "$WORK_AGENTS_DIR/agents/skills/fx-mcp/SKILL.md" <<'EOF'
---
name: fx-mcp
description: fixture with an embedded MCP server
mcp:
  fx:
    type: http
    url: https://example.invalid/mcp
---
EOF
  printf '%s\n' '# fxrepo private notes' > "$WORK_AGENTS_DIR/agents/repos/fxrepo/rules.md"
  printf '%s\n' '~/Development/fxrepo' > "$WORK_AGENTS_DIR/agents/repos/fxrepo/location"
  cat > "$WORK_AGENTS_DIR/setup.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${DOTFILES_DIR:-$HOME/.dotfiles}/agents/lib.sh"
mkdir -p "$HOME/.claude/rules" "$HOME/.claude/skills" "$HOME/Documents"
for f in "$ROOT"/agents/rules/*.md; do symlink "$f" "$HOME/.claude/rules/$(basename "$f")"; done
for s in "$ROOT"/agents/skills/*/; do symlink "${s%/}" "$HOME/.claude/skills/$(basename "$s")"; done
mkdir -p "$HOME/.config/opencode/skills"
for s in "$ROOT"/agents/skills/*/; do grep -q '^mcp:' "${s}SKILL.md" && symlink "${s%/}" "$HOME/.config/opencode/skills/$(basename "$s")"; done
link_repo_rules work "$ROOT"
mkdir -p "$HOME/.claude/skills/fx-copied" && printf -- '---\nname: fx-copied\ndescription: fixture copy\n---\n' > "$HOME/.claude/skills/fx-copied/SKILL.md" && manifest_add work "$HOME/.claude/skills/fx-copied"
for d in planning todo; do [ -d "$ROOT/$d" ] && symlink "$ROOT/$d" "$HOME/Documents/$d"; done
EOF
  chmod +x "$WORK_AGENTS_DIR/setup.sh"

  mkdir -p "$HOME/Development/fxrepo"
  git -C "$HOME/Development/fxrepo" init -q
}

assert_work_state() {
  local scenario="$1"
  local claude_stub="$HOME/Development/fxrepo/.claude/rules/work.local.md"
  local opencode_stub="$HOME/Development/fxrepo/.opencode/rules/work.local.md"
  local manifest="$HOME/.config/agents/manifest.work"
  local status_output
  local stub_lines

  [ "$(readlink "$HOME/.claude/rules/50-later.md" 2>/dev/null)" = "$WORK_AGENTS_DIR/agents/rules/50-later.md" ] ||
    fail "$scenario" "50-later.md does not point into the work fixture"
  [ "$(readlink "$HOME/.claude/skills/fx-skill" 2>/dev/null)" = "$WORK_AGENTS_DIR/agents/skills/fx-skill" ] ||
    fail "$scenario" "fx-skill does not point into the work fixture"
  [ "$(readlink "$HOME/.config/opencode/skills/fx-mcp" 2>/dev/null)" = "$WORK_AGENTS_DIR/agents/skills/fx-mcp" ] ||
    fail "$scenario" "fx-mcp is not linked into ~/.config/opencode/skills"
  if [ -e "$HOME/.config/opencode/skills/fx-skill" ] || [ -L "$HOME/.config/opencode/skills/fx-skill" ]; then
    fail "$scenario" "fx-skill (no mcp block) was linked into ~/.config/opencode/skills"
  fi
  [ -f "$claude_stub" ] || fail "$scenario" "Claude work rules stub is missing"
  [ ! -L "$claude_stub" ] || fail "$scenario" "Claude work rules stub is a symlink"
  [ "$(cat "$claude_stub")" = '@~/.work-agents/agents/repos/fxrepo/rules.md' ] ||
    fail "$scenario" "Claude work rules stub has the wrong content"
  stub_lines="$(wc -l < "$claude_stub" | tr -d '[:space:]')"
  [ "$stub_lines" = "1" ] || fail "$scenario" "Claude work rules stub is not exactly one line"
  [ "$(readlink "$opencode_stub" 2>/dev/null)" = "$WORK_AGENTS_DIR/agents/repos/fxrepo/rules.md" ] ||
    fail "$scenario" "OpenCode work rules stub has the wrong target"
  git -C "$HOME/Development/fxrepo" check-ignore -q -- '.claude/rules/work.local.md' ||
    fail "$scenario" "Claude work rules stub is not globally ignored"
  git -C "$HOME/Development/fxrepo" check-ignore -q -- '.opencode/rules/work.local.md' ||
    fail "$scenario" "OpenCode work rules stub is not globally ignored"
  status_output="$(git -C "$HOME/Development/fxrepo" status --porcelain)"
  [ -z "$status_output" ] || fail "$scenario" "fixture repository is dirty: $status_output"
  [ "$(readlink "$HOME/Documents/todo" 2>/dev/null)" = "$WORK_AGENTS_DIR/todo" ] ||
    fail "$scenario" "Documents/todo does not point into the work fixture"
  [ -f "$manifest" ] || fail "$scenario" "work manifest is missing"
  grep -qxF "$claude_stub" "$manifest" || fail "$scenario" "work manifest is missing the Claude stub"
  grep -qxF "$opencode_stub" "$manifest" || fail "$scenario" "work manifest is missing the OpenCode stub"
}

run_setup S5a
[ "$RUN_RC" -eq 1 ] || fail S5a "expected exit 1, got $RUN_RC"
grep -q -- '--profile' "$RUN_ERR" || fail S5a "stderr does not mention --profile"
pass S5a

run_setup S4 --profile work
[ "$RUN_RC" -eq 1 ] || fail S4 "expected exit 1, got $RUN_RC"
[ ! -e "$HOME/.config/agents/profile" ] || fail S4 "profile was written without a work fixture"
pass S4

run_setup S1 --profile personal
[ "$RUN_RC" -eq 0 ] || fail S1 "expected exit 0, got $RUN_RC"
[ "$(cat "$HOME/.config/agents/profile" 2>/dev/null)" = "personal" ] || fail S1 "saved profile is not personal"
S1_RULES="$(LC_ALL=C ls -1 "$HOME/.claude/rules" 2>/dev/null | LC_ALL=C sort | tr '\n' ' ' | sed 's/ $//')"
[ "$S1_RULES" = "00-engineering.md 10-karpathy.md" ] || fail S1 "unexpected Claude rules: $S1_RULES"
for S1_RULE in 00-engineering.md 10-karpathy.md; do
  S1_RULE_PATH="$HOME/.claude/rules/$S1_RULE"
  [ -L "$S1_RULE_PATH" ] || fail S1 "$S1_RULE is not a symlink"
  S1_RULE_TARGET="$(readlink "$S1_RULE_PATH")"
  case "$S1_RULE_TARGET" in
    "$DOTFILES_DIR"/*) ;;
    *) fail S1 "$S1_RULE does not point into dotfiles" ;;
  esac
done
[ "$(readlink "$HOME/.claude/CLAUDE.md" 2>/dev/null)" = "$DOTFILES_DIR/agents/claude/CLAUDE.md" ] ||
  fail S1 "CLAUDE.md has the wrong target"
[ "$(readlink "$HOME/.claude/settings.json" 2>/dev/null)" = "$DOTFILES_DIR/agents/claude/settings.json" ] ||
  fail S1 "settings.json has the wrong target"
[ -L "$HOME/.config/opencode/opencode.jsonc" ] || fail S1 "opencode.jsonc is not linked"
[ -L "$HOME/.config/opencode/AGENTS.md" ] || fail S1 "OpenCode AGENTS.md is not linked"
S1_WORK_LINKS="$(links_into_work_agents)"
[ -z "$S1_WORK_LINKS" ] || fail S1 "personal profile linked work content: $S1_WORK_LINKS"
pass S1

run_setup S5b
[ "$RUN_RC" -eq 0 ] || fail S5b "expected exit 0, got $RUN_RC"
if ! grep -q 'personal' "$RUN_OUT" && ! grep -q 'personal' "$RUN_ERR"; then
  fail S5b "output does not mention personal"
fi
pass S5b

plant_fixture
run_setup S2 --profile work
[ "$RUN_RC" -eq 0 ] || fail S2 "expected exit 0, got $RUN_RC"
assert_work_state S2
[ -d "$HOME/.claude/skills/fx-copied" ] || fail S2 "fx-copied directory is missing"
[ ! -L "$HOME/.claude/skills/fx-copied" ] || fail S2 "fx-copied is a symlink"
grep -qxF "$HOME/.claude/skills/fx-copied" "$HOME/.config/agents/manifest.work" ||
  fail S2 "work manifest is missing fx-copied"
pass S2

S6_LINKS_BEFORE="$(find "$HOME" -type l | LC_ALL=C sort)"
S6_STUB_BEFORE="$(cat "$HOME/Development/fxrepo/.claude/rules/work.local.md")"
S6_MANIFEST_LINES_BEFORE="$(wc -l < "$HOME/.config/agents/manifest.work" | tr -d '[:space:]')"
run_setup S6 --profile work
[ "$RUN_RC" -eq 0 ] || fail S6 "expected exit 0, got $RUN_RC"
S6_LINKS_AFTER="$(find "$HOME" -type l | LC_ALL=C sort)"
[ "$S6_LINKS_AFTER" = "$S6_LINKS_BEFORE" ] || fail S6 "symlink snapshot changed on rerun"
[ "$(cat "$HOME/Development/fxrepo/.claude/rules/work.local.md")" = "$S6_STUB_BEFORE" ] ||
  fail S6 "Claude work rules stub content changed on rerun"
S6_MANIFEST_LINES_AFTER="$(wc -l < "$HOME/.config/agents/manifest.work" | tr -d '[:space:]')"
[ "$S6_MANIFEST_LINES_AFTER" = "$S6_MANIFEST_LINES_BEFORE" ] ||
  fail S6 "work manifest line count changed on rerun"
pass S6

run_setup S3 --profile personal
[ "$RUN_RC" -eq 0 ] || fail S3 "expected exit 0, got $RUN_RC"
if ! grep -Eq 'WARNING.*work-agents' "$RUN_OUT" && ! grep -Eq 'WARNING.*work-agents' "$RUN_ERR"; then
  fail S3 "combined output does not warn about work-agents"
fi
S3_WORK_LINKS="$(links_into_work_agents)"
[ -z "$S3_WORK_LINKS" ] || fail S3 "personal profile retained work links: $S3_WORK_LINKS"
[ "$(cat "$HOME/.config/agents/profile" 2>/dev/null)" = "personal" ] || fail S3 "saved profile is not personal"
[ -e "$HOME/.claude/rules/00-engineering.md" ] || fail S3 "00-engineering.md was removed"
if [ -e "$HOME/Development/fxrepo/.claude/rules/work.local.md" ] || [ -L "$HOME/Development/fxrepo/.claude/rules/work.local.md" ]; then
  fail S3 "Claude work rules stub was not purged"
fi
if [ -e "$HOME/Development/fxrepo/.opencode/rules/work.local.md" ] || [ -L "$HOME/Development/fxrepo/.opencode/rules/work.local.md" ]; then
  fail S3 "OpenCode work rules stub was not purged"
fi
[ ! -e "$HOME/.claude/skills/fx-copied" ] || fail S3 "fx-copied was not purged"
[ ! -e "$HOME/.config/agents/manifest.work" ] || fail S3 "work manifest was not removed"
S3_STATUS="$(git -C "$HOME/Development/fxrepo" status --porcelain)"
[ -z "$S3_STATUS" ] || fail S3 "fixture repository is dirty: $S3_STATUS"
pass S3

S7_DOTFILES_REFS="$(tracked_home_references "$DOTFILES_DIR" dotfiles)"
[ -z "$S7_DOTFILES_REFS" ] || fail S7 "tracked dotfiles contain absolute home paths: $S7_DOTFILES_REFS"
if [ -d "$ORIG_HOME/.work-agents/.git" ]; then
  S7_WORK_REFS="$(tracked_home_references "$ORIG_HOME/.work-agents" work)"
  [ -z "$S7_WORK_REFS" ] || fail S7 "tracked work files contain absolute home paths: $S7_WORK_REFS"
else
  printf 'SKIP S7-work\n'
fi
pass S7

if [ -x "$ORIG_HOME/.work-agents/setup.sh" ]; then
  cp "$ORIG_HOME/.work-agents/setup.sh" "$WORK_AGENTS_DIR/setup.sh"
  chmod +x "$WORK_AGENTS_DIR/setup.sh"
  run_setup S8 --profile work
  [ "$RUN_RC" -eq 0 ] || fail S8 "expected exit 0, got $RUN_RC"
  assert_work_state S8
  pass S8
else
  printf 'SKIP S8\n'
fi

printf 'ALL PASS\n'
