# OpenCode setup

OpenCode is the primary coding agent on this machine. Claude Code stays installed for
two jobs it alone can do: publishing claude.ai Artifacts (see the `claude-artifact`
skill) and the claude.ai connectors that have no public MCP endpoint (Figma, Gmail,
Calendar, Drive, Amplitude).

## Layout and ownership

Two repos, one rule: **public-safe and generic → `~/.dotfiles` (public). Anything
Later-related, derived from a colleague's setup, or uncertain → `~/.work-claude`
(private).** Credentials go in neither.

| What | Tracked at | Linked to | Owner |
|---|---|---|---|
| Config: plugins, default model, providers, instructions, permissions | `agents/opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` | dotfiles |
| TUI options (theme) | `agents/opencode/tui.json` (template) | copied once to `~/.config/opencode/tui.json`; the plugin rewrites that file, so it is not a link. `theme-switch` updates both. | dotfiles |
| Global rules | `agents/opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` | dotfiles |
| oh-my-openagent routing | `agents/opencode/omo.jsonc` | `~/.omo/omo.jsonc` | dotfiles |
| Themes | `agents/opencode/themes/*.json` | `~/.config/opencode/themes/` | dotfiles |
| Generic skills | `agents/skills/<name>/` | `~/.claude/skills/<name>` | dotfiles |
| Later rules (private) | `~/.work-claude/agents/opencode/*.md` | loaded via `instructions` glob | work-claude |
| Later skills | `~/.work-claude/agents/skills/<name>/` | `~/.claude/skills/<name>` | work-claude |
| Colleague reference material | `~/.work-claude/reference/` | not loaded | work-claude |
| Provider keys | `~/.local/share/opencode/auth.json` | written by `opencode auth login` | machine only |
| MCP OAuth tokens | `~/.local/share/opencode/mcp-auth.json` | written by `opencode mcp auth` | machine only |
| Plugin install output | `~/.config/opencode/node_modules`, `package*.json` | untracked | machine only |

Files are linked individually, never the `~/.config/opencode` directory, because the
plugin installer writes into it. `setup.sh` in each repo does the linking; run it after
adding anything.

## How instructions load

1. Project `AGENTS.md` or `CLAUDE.md`, walking up from the cwd to the repo root. The
   mavely-native, mavely-next, and link-creator-extension repos already have one.
2. `~/.config/opencode/AGENTS.md` (the global rules above).
3. `~/.claude/CLAUDE.md` only as a fallback when 2 is absent. It is present, so
   CLAUDE.md is Claude-Code-only now.
4. Everything in the `instructions` array of `opencode.jsonc` is merged in: the
   Karpathy guideline and the private Later rules glob. Globs that match nothing are
   fine, so a machine without work-claude still starts.

OpenCode does not parse Claude's `@path` includes. A guideline that must load
everywhere goes in `instructions`, not in an `@` line.

There is no memory system. A rule that should survive goes into an AGENTS.md: the
global one for universal behaviour, the private Later file for team rules, the repo's
for code conventions. "Make a note" means exactly that edit.

## Add a generic skill

```bash
cd ~/.dotfiles
cp -R agents/opencode/skill-template agents/skills/<name>
$EDITOR agents/skills/<name>/SKILL.md
./setup.sh
```

Frontmatter rules (OpenCode rejects the skill otherwise):
- `name` equals the directory name: 1–64 chars, lowercase letters, digits, hyphens.
- `description` 1–1024 chars. Write it as trigger phrases; it is what the model reads
  when deciding to load the skill.

Verify: start a fresh `opencode` session in any repo and ask "what skills are
available?". The `skill` tool lists every loaded skill by name. If yours is missing,
check the symlink under `~/.claude/skills/` and the frontmatter.

Public-safe checklist before committing to dotfiles: no GitHub handles, no Linear or
other UUIDs, no IPs or hostnames, no ticket or PR numbers, no internal env var names,
no file paths inside work repos. If any of those are load-bearing, the skill belongs in
work-claude.

## Add a Later skill

Same steps in `~/.work-claude/agents/skills/<name>/`. Its `setup.sh` links every
directory automatically. Commit there. Skills that mature are promoted to
`the employer's shared skills repo`.

## Add a project skill

`<repo>/.opencode/skills/<name>/SKILL.md` (or `.claude/skills/`). Decide whether it is
tracked (team sees it) or listed in the repo's local git excludes.

## Add an MCP server

In `opencode.jsonc`:

```jsonc
"mcp": {
  "linear": {"type": "remote", "url": "https://mcp.linear.app/mcp"}
}
```

Then `opencode mcp auth linear` for OAuth servers; the token lands in
`mcp-auth.json`, not the repo. For a key-based server use `"headers":
{"Authorization": "Bearer {env:SOME_TOKEN}"}` and keep the value in an untracked
file such as `~/.secrets/<name>` sourced from the shell, or use `{file:~/.secrets/<name>}`.
Known public endpoints: Linear `https://mcp.linear.app/mcp`, Notion
`https://mcp.notion.com/mcp`, Slack `https://mcp.slack.com/mcp`, GitHub
`https://api.githubcopilot.com/mcp/`, Supabase `https://mcp.supabase.com/mcp`.
Figma's endpoint is restricted to catalogued clients and does not accept OpenCode.

## Add or tune a model

1. Add the model under `provider.<id>.models.<model-id>` in `opencode.jsonc`, with
   `variants` for effort levels (Anthropic: `thinking` + `effort`; OpenAI:
   `reasoningEffort`, `textVerbosity`).
2. Map it to an agent or category in `omo.jsonc`.
3. Confirm the ID exists: `opencode models <provider>`.

## Secrets rule

Tracked files may contain `{env:...}` or `{file:...}` references, never values.
Provider keys only ever enter through `opencode auth login`. Never store a personal
Linear API key on disk; use the OAuth MCP server.

## First-run checklist

```bash
opencode auth login                    # Anthropic (platform API key)
opencode auth login                    # OpenAI (platform API key)
opencode models anthropic              # confirm claude-fable-5-1, claude-sonnet-5, claude-haiku-4-5
opencode models openai                 # confirm gpt-5.6, gpt-6-astra; edit both .jsonc files if names differ
cd <any work repo> && opencode
```

In the session: `/models` should show only the configured models; ask "what skills
are available?" and expect `claude-artifact`, `work skills`, `zsh`,
`work skills`; run a trivial task with `ultrawork` and watch which agents and models
fire.

## omo migration error

`Migration target is not an omo config path: …/.dotfiles/agents/opencode/omo.jsonc`
means oh-my-openagent tried to run a config migration. Its writer resolves symlinks and
only accepts a file whose parent directory is literally `~/.omo`. The tracked
`omo.jsonc` carries `_migrations` markers for every migration known at setup time, so
this only recurs when a plugin update adds a new one. Fix: read the new migration id
from the plugin changelog, apply the change it describes to `omo.jsonc` by hand, add
the id to `_migrations`, and relaunch. Alternative when in a hurry: replace the link
with a real copy (`cp -L`), launch once so the plugin migrates the copy, diff the
result back into the tracked file, and restore the link with `setup.sh`.

## Artifacts

Publishing a claude.ai Artifact needs the interactive Claude Code session (verified
2026-09-18: headless `claude -p` does not expose the Artifact tool, even with
`--settings '{"enableArtifact":true}'`). The `claude-artifact` skill therefore writes
the page in OpenCode and prints a one-line `claude '...'` command for you to run; one
approval, URL printed. Re-test headless publish after major Claude Code releases:

```bash
printf '<!doctype html><title>Hello</title><body>hi</body>' > /tmp/hello.html
claude -p 'Publish /tmp/hello.html as an artifact titled "Hello" and reply with only the URL.' \
  --settings '{"enableArtifact":true}' --allowedTools 'Artifact,Read' \
  --permission-mode acceptEdits --output-format json | jq -r '.result'
```

If that ever prints a `claude.ai` URL, the skill can go back to running the command
itself.
