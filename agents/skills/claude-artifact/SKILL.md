---
name: claude-artifact
description: "Produce a claude.ai Artifact (a private, shareable web page) from OpenCode: design and write the HTML here, then hand the user a one-line Claude Code command that publishes it and prints the URL. MUST USE when the user asks for an artifact, a shareable page, a dashboard, a report or write-up for other people, an interactive demo, or says 'publish this'. Triggers: 'make an artifact', 'publish as an artifact', 'shareable page', 'give me a link I can send', 'dashboard', 'write this up for the team'."
---

# Claude artifact hand-off

OpenCode cannot publish claude.ai Artifacts. Publishing needs the `Artifact` tool,
which exists only inside an interactive Claude Code session holding the claude.ai login.
API keys cannot publish, and headless `claude -p` does not expose the tool (verified
2026-09-18). So this skill does all the thinking here, on OpenCode's routed model, and
leaves the user one command to run for the publish step.

**If you are Claude Code and the `Artifact` tool is available to you, ignore this skill
and use the tool directly.**

## When to use / when not to

- Use for anything the user will open in a browser or send to someone: reports, plans,
  dashboards, prototypes, decision write-ups.
- Do not use for code, terminal output, or a file the user will edit in the repo. For a
  public session transcript, OpenCode's `/share` exists, but it is public and not an
  artifact.

## Procedure

1. **Write the page yourself.** Save to
   `~/.local/share/opencode/artifacts/<slug>.html` (create the directory). Follow the
   page contract below. This is the deliverable; do the design work properly.
2. **Hand off the publish step.** Print this for the user, with the real path and a
   two-to-four word title, and stop:

   ```bash
   claude 'Publish ~/.local/share/opencode/artifacts/<slug>.html as an artifact titled "<Title>"; print only the URL'
   ```

   Claude Code opens, asks for one approval, publishes, and prints the URL. Tell the
   user that is what will happen. Never redo the design in that session.
3. **To update** an existing artifact, give the user the same command with the URL
   added: `... Update the artifact at <url> with that file; print only the URL`. The
   URL is kept.

## Page contract (condensed from Claude's artifact-design guidance)

- `<title>` is a two-to-four word name, not a sentence. Explanation goes in the page.
- Define colors as CSS custom properties on `:root`; redefine them under
  `@media (prefers-color-scheme: dark)` guarded by `:root:not([data-theme="light"])`
  and again under `:root[data-theme="dark"]`. Give `body` an explicit background.
- External scripts only from `cdnjs.cloudflare.com` or `cdn.jsdelivr.net/npm/`;
  stylesheets only from Google Fonts. Everything else inline.
- Works at phone width: 16px side gutter, no horizontal scroll.
- Under 16 MB including any `data:` URIs.
- No impersonation of real people or organizations, no fabricated records presented
  as genuine.

## Gotchas (verified, dated)

- 2026-09-18: `claude -p ... --settings '{"enableArtifact":true}' --allowedTools
  Artifact` does not expose the Artifact tool; the headless session reported it
  unavailable and could not approve a nested publish. Interactive `claude` is the only
  working path.
- `~/.claude/skills` is shared with Claude Code, so Claude Code also sees this skill.
  The bold note above keeps it from looping through itself.
