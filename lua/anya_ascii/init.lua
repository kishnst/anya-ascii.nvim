
local M = {}

local frames = require("anya_ascii.frames")

local function open_float()
  local columns = vim.o.columns
  local lines = vim.o.lines
  local width = math.min( math.floor(columns * 0.8), 100 )
  local height = math.min( math.floor(lines * 0.6), 30 )

  local row = math.floor((lines - height) / 2 - 1)
  local col = math.floor((columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
  vim.api.nvim_set_option_value('modifiable', true, { buf = buf })

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    noautocmd = true,
  })

  return buf, win
end

local function lines_from_frame(frame, max_width)
  local result = {}
  for line in (frame .. "\n"):gmatch("([^\n]*)\n") do
    if #line > max_width then
      local i = 1
      while i <= #line do
        table.insert(result, line:sub(i, i + max_width - 1))
        i = i + max_width
      end
    else
      table.insert(result, line)
    end
  end
  return result
end

local function play_animation(opts)
  opts = opts or {}
  local duration_ms = opts.duration_ms or 3000
  local frame_ms = opts.frame_ms or 120
  local allow_interrupt = opts.allow_interrupt ~= false

  local buf, win = open_float()
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)

  local start = vim.loop.now()
  local timer = vim.loop.new_timer()
  local idx = 1

  if allow_interrupt then
    vim.keymap.set({'n','i','v','t'}, '<Esc>', function()
      if vim.api.nvim_win_is_valid(win) then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end, { buffer = buf, nowait = true, silent = true })
  end

  timer:start(0, frame_ms, vim.schedule_wrap(function()
    if not vim.api.nvim_win_is_valid(win) then
      timer:stop(); timer:close(); return
    end

    local elapsed = vim.loop.now() - start
    if elapsed >= duration_ms then
      timer:stop(); timer:close()
      pcall(vim.api.nvim_win_close, win, true)
      return
    end

    local frame = frames[idx]
    local lines = lines_from_frame(frame, math.max(1, width - 2))
    if #lines < height then
      local pad = math.floor((height - #lines) / 2)
      local padding = {}
      for _ = 1, pad do table.insert(padding, "") end
      for _, l in ipairs(lines) do table.insert(padding, l) end
      lines = padding
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    idx = idx + 1
    if idx > #frames then idx = 1 end
  end))
end

function M.play(opts)
  play_animation(opts)
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function() play_animation({ duration_ms = 3000, frame_ms = 120 }) end, 50)
  end
})

return M
