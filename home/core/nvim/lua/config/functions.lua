local M = {}
M.notify_output = function(command, opts)
  local output = ""
  local notification
  local notify = function(msg, level)
    local notify_opts = vim.tbl_extend(
      "keep",
      opts or {},
      { title = table.concat(command, " "), replace = notification }
    )
    notification = vim.notify(msg, level, notify_opts)
  end
  local on_data = function(_, data)
    output = output .. table.concat(data, "\n")
    notify(output, "info")
  end
  vim.fn.jobstart(command, {
    on_stdout = on_data,
    on_stderr = on_data,
    on_exit = function(_, code)
      if #output == 0 then
        notify("No output of command, exit code: " .. code, "warn")
      end
    end,
  })
end

M.toggleMovement = function(first, second)
  local pos = table.concat(vim.fn.getpos('.'), ' ')
  vim.cmd('normal! ' .. first)
  if pos == table.concat(vim.fn.getpos('.'), ' ') then
    vim.cmd('normal! ' .. second)
  end
end

M.customCaseToggle = function()
  local p = vim.fn.col('.')
  local char = string.sub(vim.api.nvim_get_current_line(), p, p)
  local seq = ({
    ['-'] = '"_r_l',       -- '-' -> '_'
    ['_'] = '"_r-l',       -- '_' -> '-'
    ['"'] = '"_r\'l',      -- etc.
    ["'"] = '"_r"l',
  })[char]
  vim.cmd('normal! ' .. (seq or '~'))
end

M.bufOnly = function()
  vim.cmd('%bd|e#|bd#')
end

M.toggleQuickfix = function()
  local windows = vim.fn.getwininfo()
  for _, win in pairs(windows) do
    if win["quickfix"] == 1 then
      vim.cmd.cclose()
      return
    end
  end
  vim.cmd.copen()
end

M.getDefaultBranch = function()
  local ref = vim.fn.systemlist("git symbolic-ref refs/remotes/origin/HEAD 2> /dev/null")[1]
  if ref then
    local branch = ref:match("refs/remotes/origin/(.+)")
    if branch then
      return branch
    end
  end
  return "master" -- or main depending on our own config pref
end

M.spellQFText = function(qf_info)
  return qf_info.lnum ..":".. qf_info.col " ".. qf_info.text
end

M.spellToQF = function()
  -- Ensure spell is on
  vim.opt_local.spell = true
  vim.opt.quickfixtextfunc = "v:lua.require('config.functions').spellQFText"

  local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
  local qf = {}

  -- Put cursor on top
  vim.api.nvim_win_set_cursor(0, { 1, 1 })
  local max_seen = vim.fn.getpos('.')

  -- helper function, run normal keys ignoring keymaps
  local function normal(keys)
    vim.cmd.normal({ keys, bang = true })
  end

  -- I don't trust infinite loops
  local max_iter = vim.api.nvim_buf_line_count(0) * 10
  local iter_count = 0
  while iter_count < max_iter do
    iter_count = iter_count + 1

    -- If our line is less than our max seen
    -- or it's the same line and we're at a lower col
    -- we're looping and should exit
    local cur_pos = vim.fn.getpos('.')
    if cur_pos[2] < max_seen[2] or
      (cur_pos[2] == max_seen[2] and cur_pos[3] < max_seen[3]) then 
      break
    end
    max_seen = cur_pos

    local bad = vim.fn.spellbadword()
    local word = bad[1]
    local kind = bad[2]

    if word == "" then -- No error here, try ]s
      normal("]s")
    else -- Now at next error, loop back and let spellbadword() see it
      normal("eb")
      local pos = vim.fn.getpos('.')
      local key = pos[2] .. ":" .. pos[3]
        table.insert(qf, {
          filename = filename,
          lnum = pos[2],
          col = pos[3],
          text = word .. " (" .. kind .. ")",
        })
      normal("]s")
    end
  end

  if iter_count >= max_iter then
    print("WARNING: SpellToQF stopped after " .. max_iter .. " iterations")
  elseif #qf == 0 then
    print("No spelling errors found")
    return
  end

  vim.fn.setqflist(qf, "r")
  vim.cmd("copen | wincmd p")
end

return M
