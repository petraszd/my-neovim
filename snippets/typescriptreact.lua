local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
-- local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node

return {
  s({ trig = "state", desc = "[foo, setFoo] = useState<T>(val)" }, {
    t("const ["), i(1, "name"), t(", "), f(function(args)
    local name = args[1][1]
    if name == "" then
      return ""
    end
    return "set" .. string.upper(string.sub(name, 1, 1)) .. string.sub(name, 2, -1)
  end, { 1 }), t("] = useState<"), i(2), t(">("), i(3), t(");"), i(0),
  }),
}
