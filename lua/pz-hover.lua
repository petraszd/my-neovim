_G.pz_hover = function()
  error_float_id, hover_float_id = _get_floating_win_ids()

  local is_error_in_line = next(vim.lsp.diagnostic.get_line_diagnostics())
  if is_error_in_line then
    if error_float_id ~= nil then
      vim.api.nvim_win_close(error_float_id, false)
      _hover()
    elseif hover_float_id ~= nil then
      vim.api.nvim_win_close(hover_float_id, false)
      _error()
    else
      _error()
    end
  elseif hover_float_id == nil then
    _hover()
  else
    -- TODO: I've not figured out how to show overloaded matches:
    -- foobar(a: int);
    -- foobar(a: int, b: int);
    -- etc.
    vim.api.nvim_win_close(hover_float_id, false)
  end
end

function _hover()
  vim.lsp.buf.hover()
end

function _error()
  vim.diagnostic.open_float()
end

function _get_floating_win_ids()
  local error_float_id = nil
  local hover_float_id = nil
  local windows = vim.api.nvim_list_wins()
  for i = 1, #windows do
    if _is_floating(windows[i]) then
      if _is_error_float(windows[i]) then
        error_float_id = windows[i]
      else
        hover_float_id = windows[i]
      end
    end
  end

  return error_float_id, hover_float_id
end

function _is_floating(win_id)
  local cfg = vim.api.nvim_win_get_config(win_id)
  return cfg.relative ~= ''
end

function _is_error_float(win_id)
  local buf_id = vim.api.nvim_win_get_buf(win_id)
  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, 1, false)
  return lines[1] == "Diagnostics:"  -- Yeah... I know...
end

