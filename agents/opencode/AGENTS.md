# Global agent instructions

Loaded by OpenCode for every project on this machine (symlinked to
`~/.config/opencode/AGENTS.md`). Project `AGENTS.md` files add to this; they do not
replace it. Setup and how-to docs live in `agents/opencode/README.md`, not here.

> **"Make a note" means update an AGENTS.md.** When the user says "make a note",
> "remember this", or corrects a recurring behaviour, persist it: here if it applies
> everywhere, in the project's `AGENTS.md` if it is repo-specific. There is no other
> memory. Show the edit.

> **Execute settled decisions; don't re-litigate.** When the user gives a direct,
> reasoned instruction, do it. Raise a concern at most once, concisely. A repeated or
> reaffirmed instruction is the decision.

## Engineering principles

### Testing
TDD: tests before implementation. Every line of production code has a test.
- Write a failing test first, then make it pass.
- "Fix the bug" → write a test that reproduces it, then make it pass.
- "Add validation" → write tests for invalid inputs, then make them pass.

### Functional programming
Pure functions for all business logic. Side effects (DB writes, network calls) are
isolated to route handlers and top-level entry points. Business logic never triggers
side effects directly.

### Type safety
Never use `as` to assert a data shape. Parse and validate with a schema library (zod,
Valibot, etc.) first. `as` is only acceptable for non-shape assertions
(`undefined as unknown`, narrowing within already-validated data).

### Errors
A function that receives an error takes `unknown` and normalizes inside (e.g.
`ensureError`). Never make callers pre-wrap.

### Comments
Default to none. Add one only when the WHY is non-obvious: a hidden constraint, a
subtle invariant, a workaround for a specific bug, behaviour that would surprise a
reader. Never explain WHAT the code does.

### Security
Never introduce command injection, XSS, SQL injection, or other OWASP top-10
vulnerabilities. Validate only at system boundaries (user input, external APIs); trust
internal code and framework guarantees.

## Working with the user

- **Ask before publishing anything.** Never `gh pr create`, push a new PR branch, or
  post to a shared surface without an explicit go-ahead. Commit locally, show the diff
  and a draft title/body, then ask. Making the change is not approval to publish it.
- **Document ≠ go.** A request to outline, audit, plan, or write up a change is a
  request for the document. Implementation needs its own explicit go, even if an
  earlier message asked to implement.
- **Leave HEAD where the user put it.** Check `git branch --show-current` before acting
  on a branch assumption. Switch only when the task requires it, say so, and never
  auto-restore a "previous" branch.
- **"No sub-processes" on a review means read-only.** No subagents and no toolchain
  (tsc, eslint, jest, yarn). Use `git diff`, `git show <ref>:path`, `git grep <ref>`,
  `gh pr view/checks`. Grep the PR ref, not the working tree.
- **Verify before describing a PR.** Before drafting or editing a PR body, run
  `git diff <base>...HEAD --stat` and grep for every file or symbol you claim exists.
  The repo is right; session memory is not.
- **Rendering reports are ground truth.** If the user says output was duplicated or
  looked wrong, accept it, resend cleanly, move on. Never argue about what was "really"
  sent.
- **State a recap once.** Don't end consecutive messages with the same list of
  remaining items, and don't presuppose a fix the user hasn't chosen.
- **Research goes straight to the URL.** When the canonical page is guessable (npm
  package, GitHub repo, product docs), fetch it directly. No broad search chains for
  something the user could name in seconds; ask for the URL instead.
- **Autonomous background workers don't wait for input.** They make reasonable default
  decisions and report blockers in their output; the main session mediates all user
  interaction and pre-authorizes predictable decisions before delegating.

## Git

- Never add a `Co-Authored-By` trailer for the assistant to commit messages, in any
  repo.
- Commit or push only when asked. Branch first if on the default branch.
- Interactive git (`-i`) is unavailable; use `gh` for GitHub operations.
