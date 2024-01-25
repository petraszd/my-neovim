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

--- @param node TSNode
--- @return number
local function get_node_number(node)
  local result = 0
  local x = node
  while x ~= nil do
    x = x:prev_sibling()
    result = result + 1
  end
  return result
end

-- TODO: bufnr does not make sense if I am using vim.o.ft
local function get_treesitter_path(bufnr)
  local result = {}

  local lang = vim.treesitter.language.get_lang(vim.o.filetype)
  if lang == nil then
    return result
  end

  local node = vim.treesitter.get_node({ bufnr = bufnr })
  if node == nil then
    return result
  end

  while node ~= nil do
    table.insert(result, get_node_number(node))
    node = node:parent()
  end

  return result
end

local function find_node_by_treesitter_path(bufnr, ts_path)
  if #ts_path == 0 then
    return nil
  end

  local ts_utils = require('nvim-treesitter.ts_utils')
  local cursor_node = vim.treesitter.get_node({ bufnr = bufnr })
  if cursor_node == nil then
    return nil
  end

  local node = ts_utils.get_root_for_node(cursor_node)
  local idx = #ts_path - 1

  while idx > 0 do
    node = node:child(ts_path[idx] - 1)
    idx = idx - 1
  end

  return node
end

_M.pz_format = function(bufnr)
  save_if_unsaved(bufnr)

  local ts_path = get_treesitter_path(bufnr)

  if is_prettier_buffer(bufnr) then
    format_using_prettier(bufnr)
  elseif is_sql_buffer(bufnr) then
    format_using_sql_formatter(bufnr)
  else
    vim.lsp.buf.format({
      bufnr = bufnr,
      timeout_ms = 10000,
      async = false,
    })
  end

  -- Need to defer call. Otherwise treesitter is going to be in invalid state
  -- and will give bogus coordinates.
  --
  -- TODO: maybe it is possible to to get fresh tree without a defer ?
  vim.defer_fn(function()
    if #ts_path == 0 then
      return
    end

    local node = find_node_by_treesitter_path(bufnr, ts_path)
    if node == nil then
      return
    end
    local r, c = node:start()
    -- TODO: check if previous node position was the same as now
    -- TODO: you need an end as well
    vim.api.nvim_win_set_cursor(0, { r + 1, c })
  end, 1)
end

return _M;
