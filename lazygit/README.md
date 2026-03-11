# lazygit

Lazygit config lives at `lazygit/config.yml` and is symlinked to `~/.config/lazygit`.

## AI commit flow

- `A`: Generate/refresh AI commit draft with visible loading feedback
- `E`: Open editable commit summary/description prefilled from cached AI draft, then commit

The AI helper script is `lazygit/scripts/lazygit-ai-commit-draft`.

## Model configuration

The script defaults to `opencode/minimax-m2.5-free` and falls back to `opencode/gpt-5-nano`.

Optional environment overrides:

- `LAZYGIT_AI_COMMIT_MODEL`
- `LAZYGIT_AI_COMMIT_FALLBACK_MODEL`
- `LAZYGIT_AI_COMMIT_VARIANT` (default: `minimal`)
- `LAZYGIT_AI_COMMIT_STRICT_PRIMARY=1` (disable fallback)
