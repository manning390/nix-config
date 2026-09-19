local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("ts", {
        t('<script lang="ts">'),
        t({"", "\t"}),
        i(1),
        t({"", "</script>", ""}),
        i(0),
    }),
}
