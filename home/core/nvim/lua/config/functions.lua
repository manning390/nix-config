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
	vim.cmd('normal! '..first)
	if pos == table.concat(vim.fn.getpos('.'), ' ') then
		vim.cmd('normal! '..second)
	end
end

M.customCaseToggle = function()	
    local p = vim.fn.col('.')
    local char = string.sub(vim.api.nvim_get_current_line(), p, p)
    local seq = ({
        ['-']  = '"_r_l',  -- '-' -> '_'
        ['_']  = '"_r-l',  -- '_' -> '-'
        ['"']  = '"_r\'l', -- etc.
        ["'"]  = '"_r"l',
    })[char]
    vim.cmd('normal! '..(seq or '~'))
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

return M
