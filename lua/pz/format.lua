local _M = {}

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

  local job_status = vim.fn.jobwait({ job_id }, 10000)
  if job_status[1] == -1 then
    vim.fn.jobstop(job_id)
  end
end

local function format_using_prettier(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local cmd = {"prettier", filename}
  manual_format(bufnr, cmd)
end

local function format_using_sql_formatter(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local cmd = {"sql-formatter", filename}
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

--- @param bufnr number
--- @return any[]
local function get_treesitter_path(bufnr)
  --- @type any[]
  local result = {}

  local node = vim.treesitter.get_node({ bufnr = bufnr })
  if node == nil then
    return result
  end

  while node ~= nil do
    table.insert(result, node:id())
    node = node:parent()
  end

  return result
end

_M.pz_format = function(bufnr)
  -- local ts_path = get_treesitter_path(bufnr)

  if is_prettier_buffer(bufnr) then
    format_using_prettier(bufnr)
  elseif is_sql_buffer(bufnr) then
    format_using_sql_formatter(bufnr)
  else
    vim.lsp.buf.format({
      bufnr = bufnr,
      timeout_ms = 10000,
    })
  end

  local root = vim.treesitter.get_node({ bufnr = bufnr })
  if root == nil then
    return
  end

  while root:parent() ~= nil do
    root = root:parent()
  end

  -- vim.print(ts_path[#ts_path] == root:id())
  -- TODO: continue here
end

return _M;
