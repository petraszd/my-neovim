local _M = {}

--- @class Color
--- @field line string
--- @field hex string
--- @field lnum number
--- @field col number
--- @field len number
local Color = {}
Color.__index = Color
--- @param hex string
--- @param lnum integer
--- @param col integer
--- @param len integer
--- @return Color
function Color:new(bufnr, hex, lnum, col, len)
  local obj = setmetatable({
    line = vim.trim(
      vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)[1]
    ),
    hex = hex,
    lnum = lnum,
    col = col,
    len = len,
  }, self)
  return obj
end

--- @param raw_color string
--- @return string
local function normalize_hex_color(raw_color)
  if #raw_color == 7 then
    return raw_color
  end

  if #raw_color == 4 then
    local r = string.sub(raw_color, 2, 2)
    local g = string.sub(raw_color, 3, 3)
    local b = string.sub(raw_color, 4, 4)
    return "#" .. r .. r .. g .. g .. b .. b
  end

  error("normalize_hex_color: I do not know how to deal with :" .. raw_color)
end

--- @param bufnr number
--- @return Color[]
local function _get_colors(bufnr)
  --- @type Color[]
  local result = {}

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  local ints_pattern = "()(%d+)%s*,%s*(%d+)%s*,%s*(%d+)()"
  local hex3_pattern = "()(#%x%x%x)[%X$]"
  local hex6_pattern = "()(#%x%x%x%x%x%x)[%X$]"

  for lnum, line in ipairs(lines) do
    for pos1, c1, c2, c3, pos2 in string.gmatch(line, ints_pattern) do
      local r = tonumber(c1)
      local g = tonumber(c2)
      local b = tonumber(c3)
      if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
        local hex = string.format("#%02x%02x%02x", r, g, b)
        local col = tonumber(pos1) or 1
        table.insert(result, Color:new(bufnr, hex, lnum, col - 1, pos2 - pos1))
      end
    end

    for pos, hex in string.gmatch(line, hex3_pattern) do
      local col = tonumber(pos) or 0
      table.insert(result, Color:new(bufnr, normalize_hex_color(hex), lnum, col - 1, 4))
    end

    for pos, hex in string.gmatch(line, hex6_pattern) do
      local col = tonumber(pos) or 0
      table.insert(result, Color:new(bufnr, normalize_hex_color(hex), lnum, col - 1, 7))
    end
  end

  return result
end

_M.open = function(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  local colors = _get_colors(bufnr)
  local items = {}
  for i, c in pairs(colors) do
    table.insert(items, {
        idx = i,
        score = 1,  -- TODO: what ?
        pos = { c.lnum, c.col },
        end_pos = { c.lnum, c.col + c.len },
        file = bufname,
        line = "XXXXXX " .. c.line,
        text= c.line,
    })
  end

  local p = require("snacks").picker(nil, {
    -- TODO bufname is too long
    title = "Colors in " .. bufname,
    items = items,
  })

  -- vim.print({"B FROM W", vim.api.nvim_win_get_buf(p.list.win.win)})
  -- vim.print({"B FROM B", p.list.win.buf })
end

return _M


