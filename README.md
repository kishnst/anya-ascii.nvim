# anya-ascii.nvim

Basically Anya ASCII art in nvim, you don’t need to do anything — when you open Vim, Anya will already appear for ~3 seconds and then go away

- Uses the ASCII frames 
- No external dependencies.
- ESC closes early.

## Install (lazy.nvim)

```lua
-- in your plugins spec
{ "local/anya-ascii.nvim",
  dir = vim.fn.stdpath("data") .. "/anya-ascii.nvim", -- for local testing
  lazy = false,
}
```
Or

Put this folder in your ~/.config/nvim/pack/anya/start/anya-ascii.nvim (yes, I also copy-pasted this path many times to remember).

## Usage

- Plays automatically on `VimEnter`.
- Manual: `:lua require("anya_ascii").play({ duration_ms = 3000, frame_ms = 120 })`

## Notes
- Frames were parsed using a regex.

- Escape key also works like “go away Anya” button.

- Only works in Neovim (because floating window). Sorry Vim-only gang.

- If something breaks, probably my fault. Please send me message, I will fix it.

- Feel free to contribute newer features.
