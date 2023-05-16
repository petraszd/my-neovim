local _M = {}

local function format_using_pretter(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)

  local cmd = {"prettier", filename}
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

  local job_status = vim.fn.jobwait({ job_id }, 10000)
  if job_status[1] == -1 then
    vim.fn.jobstop(job_id)
  end
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

_M.pz_format = function(bufnr)
  if is_prettier_buffer(bufnr) then
    format_using_pretter(bufnr)
  else
    vim.lsp.buf.format({
      bufnr = bufnr,
      timeout_ms = 10000,
    })
  end
end

return _M;

