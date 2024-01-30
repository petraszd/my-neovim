local _M = {}

local FMT_TIMEOUT = 10000

local function manual_format(bufnr, cmd)
  local stdout = {}
  local job_id = vim.fn.jobstart(cmd, {
    clear_env = false,
    stdout_buffered = true,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        return
      end
      if #stdout == 0 then
        return
      end
      if stdout[#stdout] == "" then
        table.remove(stdout, #stdout)
      end
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, stdout)
    end,
    on_stdout = function(_, data, _)
      stdout = data
    end,
  })

  local job_status = vim.fn.jobwait({ job_id }, FMT_TIMEOUT)
  if job_status[1] == -1 then
    vim.fn.jobstop(job_id)
  end
end

local function format_using_prettier(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local cmd = { "prettier", filename }
  manual_format(bufnr, cmd)
end

local function format_using_sql_formatter(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local cmd = { "sql-formatter", filename }
  manual_format(bufnr, cmd)
end

local function is_prettier_buffer(bufnr)
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  for _, c in ipairs(clients) do
    -- Not sure if checking just for tsserver and eslint is good enough
    if c.name == "tsserver" or c.name == "eslint" then
      return true
    end
  end

  return false
end

local function is_sql_buffer(bufnr)
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  for _, c in ipairs(clients) do
    if c.name == "sqlls" then
      return true
    end
  end
  return false
end

local function save_if_unsaved(bufnr)
  if vim.fn.getbufinfo(bufnr)[1].changed == 1 then
    vim.cmd.write({ bang = true })
  end
end

_M.pz_format = function(bufnr)
  save_if_unsaved(bufnr)

  if is_prettier_buffer(bufnr) then
    format_using_prettier(bufnr)
  elseif is_sql_buffer(bufnr) then
    format_using_sql_formatter(bufnr)
  else
    vim.lsp.buf.format({
      bufnr = bufnr,
      timeout_ms = FMT_TIMEOUT,
      async = false,
    })
  end
end

return _M;
