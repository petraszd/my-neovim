local _M = {}

-- TODO: rename
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")

local pz_colors_ns = vim.api.nvim_create_namespace("PZ_Colors_NS")

--- @class Color
--- @field line string
--- @field hex string
--- @field lnum number
--- @field col number
local Color = {}
Color.__index = Color

--- @param bufnr number
--- @param hex string
--- @param node TSNode
--- @return Color
function Color:new(bufnr, hex, node)
  local start_row, start_col, _, _ = node:range()
  local obj = setmetatable({
    line = vim.trim(
      vim.api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, true)[1]
    ),
    hex = hex,
    lnum = start_row + 1,
    col = start_col + 1,  -- TODO: not sure about +1
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
local function get_colors(bufnr)
  local ts_utils = require("nvim-treesitter.ts_utils")

  --- @type Color[]
  local result = {}

  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local lang = vim.treesitter.language.get_lang(ft)
  if lang == nil then
    return result
  end

  local cursor_node = vim.treesitter.get_node({ bufnr = bufnr })
  if cursor_node == nil then
    return result
  end

  local root_node = ts_utils.get_root_for_node(cursor_node)
  local num_lines = vim.api.nvim_buf_line_count(bufnr)

  --- TODO: comment
  local hex_query = vim.treesitter.query.parse(lang, "(color_value) @val")
  for _, match, _ in hex_query:iter_matches(root_node, bufnr, 0, num_lines + 1) do
    local node = match[1]
    local hex = vim.treesitter.get_node_text(node, bufnr)
    table.insert(result, Color:new(bufnr, normalize_hex_color(hex), node))
  end

  --- TODO: comment
  local rgba_query = vim.treesitter.query.parse(lang, [[
    (call_expression
      (function_name) @name
      (arguments
        (integer_value) @r
        (integer_value) @g
        (integer_value) @b
        (float_value)))
  ]])
  for _, match, _ in rgba_query:iter_matches(root_node, bufnr, 0, num_lines + 1) do
    local node = match[1]
    local func_name = vim.treesitter.get_node_text(node, bufnr)
    if func_name:lower() == "rgba" then
      local r = tonumber(vim.treesitter.get_node_text(match[2], bufnr))
      local g = tonumber(vim.treesitter.get_node_text(match[3], bufnr))
      local b = tonumber(vim.treesitter.get_node_text(match[4], bufnr))
      if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
        local hex = string.format("#%02x%02x%02x", r, g, b)
        table.insert(result, Color:new(bufnr, hex, node))
      end
    end
  end

  return result
end

function _M.display_colors()
  local bufnr = 0
  local opts = {}

  local bufname = vim.api.nvim_buf_get_name(bufnr)

  local colors = get_colors(bufnr)

  local n = 0
  local hex_to_hl = {}
  for _, c in ipairs(colors) do
    if hex_to_hl[c.hex] == nil then
      n = n + 1
      local hl = "PetrasHL_" .. n
      hex_to_hl[c.hex] = hl
      vim.api.nvim_set_hl(pz_colors_ns, hl, { fg = c.hex, bg = c.hex })
    end
  end

  local picker = pickers.new(opts, {
    prompt_title = "TODO: TreeSitter Colors",
    results_title = "TODO: RESULT TITLE",
    preview_title = "TODO: PREVIEW TITLE",
    finder = finders.new_table {
      results = colors,
      --- @param color Color
      entry_maker = function(color)
        return make_entry.set_default_entry_mt({
          value = color.line,
          ordinal = color.line,
          display = function(entry)
            local hl = hex_to_hl[color.hex]
            return "XXXXXX " .. entry.ordinal, { { { 0, 6 }, hl } }
          end,
          filename = bufname,
          lnum = color.lnum,
          start = color.lnum,
          col = color.col,
        }, opts)
      end
    },
    previewer = conf.grep_previewer(opts),
    sorter = conf.generic_sorter(opts),
    push_cursor_on_edit = true,
    push_tagstack_on_edit = true,
  })
  picker:find()

  if picker.results_win ~= nil then
    vim.api.nvim_win_set_hl_ns(picker.results_win, pz_colors_ns)
    -- TODO:
    -- TODO: on close clear HL
    -- vim.api.nvim_buf_attach
  end

end

return _M