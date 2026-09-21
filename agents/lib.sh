# Shared helpers for agent setup links, repository rules, and layer manifests.
# Sourced by both ~/.dotfiles/setup.sh and ~/.work-agents/setup.sh.

symlink() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      echo "  already linked: $dst"
    else
      ln -sfn "$src" "$dst"
      echo "  relinked: $dst → $src"
    fi
  elif [ -e "$dst" ]; then
    echo "  WARNING: $dst exists and is not a symlink — skipping (move it manually)"
  else
    ln -s "$src" "$dst"
    echo "  linked: $dst → $src"
  fi
}

remove_dangling_links() {
  local dir="$1"
  local link

  [ -d "$dir" ] || return 0

  while IFS= read -r link; do
    if [ ! -e "$link" ]; then
      rm "$link"
      echo "  removed dangling: $link"
    fi
  done < <(find "$dir" -maxdepth 1 -type l -print)
}

prune_links_into() {
  local dir="$1"
  local root="$2"
  local rroot
  local link
  local raw
  local resolved
  local should_prune

  [ -d "$dir" ] || return 0

  rroot="$(cd "$root" 2>/dev/null && pwd -P || printf '%s\n' "$root")"

  while IFS= read -r link; do
    raw="$(readlink "$link" 2>/dev/null || true)"
    resolved="$(readlink -f "$link" 2>/dev/null || true)"
    should_prune=0

    case "$raw" in
      "$root"/*) should_prune=1 ;;
    esac
    case "$resolved" in
      "$rroot"/*) should_prune=1 ;;
    esac

    if [ "$should_prune" -eq 1 ]; then
      rm "$link"
      echo "  pruned work link: $link"
    fi
  done < <(find "$dir" -maxdepth 1 -type l -print)
}

expand_tilde() {
  local path="$1"

  case "$path" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s\n' "$HOME/${path#\~/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

manifest_add() {
  local layer="$1"
  local path="$2"
  local manifest="$HOME/.config/agents/manifest.${layer}"

  mkdir -p "$HOME/.config/agents"
  if [ ! -f "$manifest" ] || ! grep -qxF "$path" "$manifest"; then
    printf '%s\n' "$path" >> "$manifest"
  fi
}

manifest_purge() {
  local layer="$1"
  local manifest="$HOME/.config/agents/manifest.${layer}"
  local path
  local parent
  local count=0

  [ -f "$manifest" ] || return 0

  while IFS= read -r path || [ -n "$path" ]; do
    case "$path" in
      "$HOME"/*) ;;
      *) continue ;;
    esac

    if [ -L "$path" ] || [ -f "$path" ]; then
      rm -f "$path"
      count=$((count + 1))
    elif [ -d "$path" ] && [ ! -L "$path" ]; then
      rm -rf "$path"
      count=$((count + 1))
    fi

    parent="$(dirname "$path")"
    case "$parent" in
      */.claude/rules | */.opencode/rules) rmdir "$parent" 2>/dev/null || true ;;
    esac
  done < "$manifest"

  rm -f "$manifest"
  echo "  purged $count $layer artifacts"
}

link_repo_rules() {
  local layer="$1"
  local layer_root="$2"
  local repos="$layer_root/agents/repos"
  local import
  local location
  local entry
  local name
  local rules
  local raw_location
  local repo
  local inside_work_tree
  local stub
  local opencode_link
  local want

  [ -d "$repos" ] || return 0

  case "$layer_root" in
    "$HOME"/*) import="~/${layer_root#"$HOME"/}" ;;
    *) import="$layer_root" ;;
  esac

  for location in "$repos"/*/location; do
    [ -f "$location" ] || continue

    entry="${location%/location}"
    name="${entry##*/}"
    rules="$entry/rules.md"
    raw_location="$(head -n 1 "$location")"
    repo="$(expand_tilde "$raw_location")"

    [ -d "$repo" ] || continue
    inside_work_tree="$(git -C "$repo" rev-parse --is-inside-work-tree 2>/dev/null || true)"
    [ "$inside_work_tree" = "true" ] || continue
    [ -f "$rules" ] || continue

    mkdir -p "$repo/.claude/rules" "$repo/.opencode/rules"
    stub="$repo/.claude/rules/${layer}.local.md"
    opencode_link="$repo/.opencode/rules/${layer}.local.md"
    want="@${import}/agents/repos/${name}/rules.md"

    if [ -L "$stub" ] || [ ! -f "$stub" ] || ! cmp -s <(printf '%s\n' "$want") "$stub"; then
      if [ -L "$stub" ]; then
        rm -f "$stub"
      fi
      printf '%s\n' "$want" > "$stub"
    fi

    symlink "$rules" "$opencode_link"
    manifest_add "$layer" "$stub"
    manifest_add "$layer" "$opencode_link"
    echo "  wired repo rules: $name → $repo"
  done
}
