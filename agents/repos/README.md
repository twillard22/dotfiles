# Per-repo private notes

Each entry uses:

- `agents/repos/<name>/location`: one `~/`-relative path to the repo.
- `agents/repos/<name>/rules.md`: private notes in Markdown.

`setup.sh` writes the two ignored stubs into the repo. Promote a note by moving its
content into `<repo>/AGENTS.md`.

Only personal repos belong here. Work repos live in `~/.work-agents/agents/repos/`.
