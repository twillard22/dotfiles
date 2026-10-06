# OpenCode setup

OpenCode is the primary coding agent on this machine. Claude Code stays installed for
two jobs it alone can do: publishing claude.ai Artifacts (see the `claude-artifact`
skill) and the claude.ai connectors that have no public MCP endpoint (Gmail,
Calendar, Drive, Amplitude; Figma's remote server is allowlisted, see below).

## Layout and ownership

Two repos, one rule: **public-safe and generic → `~/.dotfiles` (public). Anything
Later-related, derived from a colleague's setup, or uncertain → `~/.work-agents`
(private).** Credentials go in neither.

| What | Tracked at | Linked to | Owner |
|---|---|---|---|
| Config: plugins, default model, providers, instructions, permissions | `agents/opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` | dotfiles |
| TUI options (theme) | `agents/opencode/tui.json` (template) | copied once to `~/.config/opencode/tui.json`; the plugin rewrites that file, so it is not a link. `theme-switch` updates both. | dotfiles |
| Thin OpenCode notes (pointer to the rules dir, not rules) | `agents/opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` | dotfiles |
| Generic rules | `agents/rules/00-engineering.md` | `~/.claude/rules/00-engineering.md`, loaded via `instructions` | dotfiles |
| Karpathy guideline | `agents/guidelines/karpathy/` (submodule) | `~/.claude/rules/10-karpathy.md`, loaded via `instructions` | dotfiles |
| oh-my-openagent routing | `agents/opencode/omo.jsonc` | `~/.omo/omo.jsonc` | dotfiles |
| Themes | `agents/opencode/themes/*.json` | `~/.config/opencode/themes/` | dotfiles |
| Generic skills | `agents/skills/<name>/` | `~/.claude/skills/<name>` | dotfiles |
| Later rules (private) | `~/.work-agents/agents/rules/50-later.md` | `~/.claude/rules/50-later.md`, loaded via `instructions` (work profile only) | work-agents |
| Per-repo private notes | `<layer>/agents/repos/<name>/{location,rules.md}` | `<repo>/.claude/rules/<layer>.local.md` (real stub, `@~/...` import) + `<repo>/.opencode/rules/<layer>.local.md` (symlink), both loaded via `instructions` | dotfiles or work-agents |
| Later skills | `~/.work-agents/agents/skills/<name>/` | `~/.claude/skills/<name>` | work-agents |
| Employer org skills | employer's shared skills repo (external) | copied (not symlinked) into `~/.claude/skills/<name>` by `~/.work-agents/setup.sh` | work-agents |
| Provider keys | `~/.local/share/opencode/auth.json` | written by `opencode auth login` | machine only |
| MCP OAuth tokens | `~/.local/share/opencode/mcp-auth.json` | written by `opencode mcp auth` | machine only |
| Plugin install output | `~/.config/opencode/node_modules`, `package*.json` | untracked | machine only |

Files are linked individually, never the `~/.config/opencode` directory, because the
plugin installer writes into it. `setup.sh` in each repo does the linking; run it after
adding anything.

## How instructions load

Both tools read the same merged rules directory, `~/.claude/rules/*.md`: Claude Code reads it
natively, OpenCode via the `instructions` array in `opencode.jsonc`:

```jsonc
"instructions": [
  "~/.claude/rules/*.md",
  ".claude/rules/*.md",
  ".opencode/rules/*.md"
]
```

`~/.claude/rules/*.md` picks up everything `setup.sh` links there: `00-engineering.md`
(generic), `10-karpathy.md` (submodule), and — on the work profile — `50-later.md`. The two
relative globs are evaluated at every directory from the cwd up to the git root, so a repo's
own `.claude/rules/*.md` and `.opencode/rules/*.md` load too, including a repo's own
`AGENTS.md`/`CLAUDE.md` walking up from the cwd. Globs that match nothing are fine, so a
machine without `~/.work-agents` still starts.

Per-repo private notes show up as `<repo>/.claude/rules/<layer>.local.md`, a real one-line
`@~/<layer-repo>/agents/repos/<name>/rules.md` stub. OpenCode has no `@` import syntax, so it
ignores that line's content — but the matching `<repo>/.opencode/rules/<layer>.local.md`
symlink in the same `instructions` glob carries the actual note, so nothing is lost. Restart
OpenCode after any change to `opencode.jsonc` or the rules it loads.

There is no memory system. A rule that should survive goes into the owning layer's rules
file — `agents/rules/00-engineering.md` (this repo, generic), `~/.work-agents/agents/rules/
50-later.md` (work), `<layer>/agents/repos/<name>/rules.md` (private per-repo), or
`<repo>/AGENTS.md` (team-visible). "Make a note" means exactly that edit.

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
work-agents.

## Add a Later skill

Same steps in `~/.work-agents/agents/skills/<name>/`. Its `setup.sh` links every
directory automatically. Commit there. Skills that mature are promoted to the
employer's shared skills repo.

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
Figma's remote endpoint (`https://mcp.figma.com/mcp`) is allowlisted to catalogued
clients: its registration endpoint issues a client ID, then the authorize page says
"OAuth app with client id … doesn't exist". Neither official server accepts a personal
access token, so `figma` is the Framelink server (`figma-developer-mcp`, stdio) over
the REST API with a read-only token in `~/.secrets/figma` (`chmod 600`, one line). Its
two tools (`get_figma_data`, `download_figma_images`) take a file key + node id from any
Figma URL; no open Desktop app required, no generated code or screenshots either. Like
Linear and Notion it is `enabled: false` here and loads through the `figma` skill in
`~/.work-agents/agents/skills/figma`; that skill's frontmatter wraps the command in
`sh -c 'FIGMA_API_KEY="$(cat ~/.secrets/figma)" exec npx …'` because the skill loader
strips inherited `*_API_KEY` vars and does no `{env:}`/`{file:}` substitution. If
`get_design_context`/`get_screenshot` are ever needed, the Desktop Dev Mode server is
`{"type": "remote", "url": "http://127.0.0.1:3845/mcp", "oauth": false}` (Figma Desktop
→ Dev Mode → Cmd+K → "Enable Dev Mode MCP server", file open; ~5K tokens per turn).

**Every server listed here costs its full tool-schema size on every turn of every
session**, used or not. Measure before adding: `tools/list` on Notion is ~63K tokens,
Linear ~28K, Figma Desktop ~5K. Anything over a few K tokens that is not needed in most
sessions goes behind a skill instead: keep the `opencode.jsonc` entry with
`"enabled": false` (so `opencode mcp list` still shows it) and declare the server in the
skill's frontmatter — see `~/.work-agents/agents/skills/linear/SKILL.md`:

```yaml
mcp:
  linear:
    type: http
    url: https://mcp.linear.app/mcp
    oauth: {}
```

oh-my-openagent connects it when the skill is loaded, appends the tool list to the skill
body, and the model calls tools via `skill_mcp(mcp_name=…, tool_name=…)`. Its OAuth
tokens live in `~/.config/opencode/mcp-oauth/` (first use opens a browser), separate from
`opencode mcp auth`. The skill `description` is what triggers the load, so write it as
the phrases that mean "this session needs Linear".

## Cost review

The fixed per-turn context is the cost lever: it is written to cache on turn 1 and
re-read on every later turn, for the orchestrator and for every sub-agent that inherits
it. Review weekly with:

```bash
opencode stats --days 7 --models
# first-turn context (cache write) per session, newest first
sqlite3 ~/.local/share/opencode/opencode.db "select substr(s.title,1,40), json_extract(m.data,'\$.modelID'), json_extract(m.data,'\$.tokens.cache.write'), round(json_extract(m.data,'\$.cost'),2), date(m.time_created/1000,'unixepoch') from session s join message m on m.session_id=s.id where s.parent_id is null and json_extract(m.data,'\$.role')='assistant' and json_extract(m.data,'\$.tokens.cache.write')>0 group by s.id having m.time_created=min(m.time_created) order by m.time_created desc limit 20;"
```

Baseline, 2026-09-22 (7 days ending that day, before the change below): 36 sessions,
$278.82 total, $39.83/day, Fable $260 (93%), 267M cache-read tokens vs 16.4M cache-write.
A Fable session in mavely-native opened at **205K tokens / $2.58** before the first reply;
~92K of that was Notion + Linear tool schemas, ~10K duplicate and plugin skills.

Change on 2026-09-22: Linear and Notion moved behind skills (above), Claude Code compat
skill loader and the figma/supabase Claude Code plugins turned off in `omo.jsonc`.
Same-model A/B with a fresh `opencode run` in mavely-native: **152K → 48K tokens**
(haiku). First real Fable session on the new setup ("Initial influx testing",
2026-09-22 10:55): **67,793 tokens / $0.85**, down from 204,842 / $2.58.

Review, 2026-10-06 (`--days 14`, the two weeks after the 09-22 change): 79 sessions,
$1,010.73, **$72.19/day**, Fable $986 (97.5%). First-turn context did drop as expected,
but per-day spend went up because the weeks were busier (several 200–500 message review
sessions, one at $165). Fable's bill broken down by token line: cache **write** 53.9M ×
$12.50 = **$674**, cache read 826M × $0.25 = $207, output 2.1M × $50 = $105. So the
cache-write price, not cache-read, is the number a model swap has to move — every
tool-heavy turn appends ~15K tokens written at 50× the read price.

Why the orchestrator carries 97%: the cheap-worker tiers in `omo.jsonc` almost never
fire. In 14 days `task` ran 14 times (5 oracle, 4 librarian, 2 unspecified-high, 1 deep,
zero explore/quick/visual-engineering) against 3,698 orchestrator turns; `edit`+`write`
were 6.5% of tool calls; the top bash commands were `gh pr`, `sed -n`, `python3 -`,
`grep -n`, `git show`, `git diff`, plus 445 Linear MCP calls. Roughly 85% of top-session
spend was PR review, handoff/completion review, requirements and Linear status — work
whose output is prose for the user and has to flow through the orchestrator's context
anyway. That is the workload, not a bug: the Sisyphus prompt reserves delegate-by-default
for implementation, and the rules ("no sub-processes on a review", "research goes straight
to the URL", review output drafted for approval) point the same way. Forcing delegation
on reviews would be lossy; making the orchestrator cheaper is the lever. Queries used:

```bash
# tool calls by name
sqlite3 ~/.local/share/opencode/opencode.db "select json_extract(p.data,'\$.tool'), count(*) from part p join message m on m.id=p.message_id where json_extract(p.data,'\$.type')='tool' and m.time_created > (strftime('%s','now')-14*86400)*1000 group by 1 order by 2 desc;"
# assistant turns and cost by agent + model (child sessions included)
sqlite3 ~/.local/share/opencode/opencode.db "select json_extract(m.data,'\$.agent'), json_extract(m.data,'\$.modelID'), count(*), round(sum(json_extract(m.data,'\$.cost')),2) from message m where json_extract(m.data,'\$.role')='assistant' and m.time_created > (strftime('%s','now')-14*86400)*1000 group by 1,2 order by 3 desc;"
# sessions by cost, with cache-write / cache-read in millions
sqlite3 ~/.local/share/opencode/opencode.db "select substr(s.title,1,45), count(*), round(sum(json_extract(m.data,'\$.cost')),2), round(sum(json_extract(m.data,'\$.tokens.cache.write'))/1e6,1), round(sum(json_extract(m.data,'\$.tokens.cache.read'))/1e6,1) from session s join message m on m.session_id=s.id where json_extract(m.data,'\$.role')='assistant' and m.time_created > (strftime('%s','now')-14*86400)*1000 group by s.id order by 3 desc limit 12;"
```

Change on 2026-10-06, priced on the measured 14-day token mix (prices from
`https://models.dev/api.json`, per 1M tokens in / out / cache-read / cache-write):

| model | in/out | cache r/w | same workload | note |
|---|---|---|---|---|
| claude-fable-5-1 (before) | 10 / 50 | 0.25 / 12.50 | $986 | |
| **claude-opus-5-5** (after) | 4 / 20 | 0.20 / 5.00 | **~$477** | released 09-22; same 1M ctx, same 2026-06 cutoff, same effort ladder |
| claude-sonnet-5-5 | 2 / 10 | 0.20 / 2.50 | ~$321 | the next step down |
| claude-opus-5 / opus-4-8 | 5 / 25 | 0.50 / 6.25 | ~$802 | trap: only Opus 5.5 has the cheap cache tier |
| gpt-6.1-sol | 2 / 10 | 0.10 / 2.50 | ~$238 | |

- `sisyphus` → `anthropic/claude-opus-5-5`, reasoning `medium` (was Fable 5.1). Opus
  first rather than Sonnet because the orchestrator is doing the actual review work, so
  its quality matters more than "orchestrator" implies. `model` in `opencode.jsonc`
  tracks it so plain `build` sessions get the same price.
- `gpt-5.6` → `openai/gpt-6.1-sol` on `hephaestus`, `metis`, `momus`,
  `unspecified-low/high`. gpt-5.6's canonical id is `gpt-5.6-sol`; 6.1-sol is its
  successor in the same family (released 09-29, "near-Astra performance at a lower
  cost"), half the price, newer cutoff.
- `claude-sonnet-5` → `claude-sonnet-5-5` on `librarian`, `atlas`, `multimodal-looker`,
  `visual-engineering`, `artistry`, `writing`. Same price, released 09-28.
- Unchanged: `prometheus` (Fable/max), `oracle` + `ultrabrain` + `deep` (gpt-6-astra/max),
  `explore` + `quick` (haiku-4-5). Low volume (under $20 combined), exactly where the top
  model belongs.
- Deliberately not done: a "multi-file implementation goes to `hephaestus`" rule. Worth
  maybe $50–70 per two weeks on this workload; revisit only if the stats after the swap
  show implementation sessions dominating.

Review on or after 2026-10-13 (ask: "we moved sisyphus to opus-5-5 on 10-06, compare the
stats"): rerun `opencode stats --days 7 --models` and the per-session query. `--days 7`
on 10-13 straddles the change, so prefer `--days 6`. Expect Avg Cost/Day near **$37** on
comparable work, with `claude-opus-5-5` where Fable was. Then decide on quality, not
just cost: if Opus feels fine and more saving is wanted, `sisyphus` →
`anthropic/claude-sonnet-5-5` (another ~$150 per two weeks); if quality slipped, the
first knob is `"reasoning": "high"` on Opus, not reverting to Fable.

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
~/.dotfiles/setup.sh --profile work      # links rules, skills, per-repo stubs; installs the org skill
opencode auth login                      # Anthropic (platform API key)
opencode auth login                      # OpenAI (platform API key)
opencode models anthropic                # confirm claude-opus-5-5, claude-fable-5-1, claude-sonnet-5-5, claude-haiku-4-5
opencode models openai                   # confirm gpt-6.1-sol, gpt-6-astra; edit both .jsonc files if names differ
cd <any work repo> && opencode
```

In the session: `/models` should show only the configured models; ask "what skills
are available?" and expect `claude-artifact` plus every skill linked from
`~/.work-agents`; run a trivial task with `ultrawork` and
watch which agents and models fire.

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
