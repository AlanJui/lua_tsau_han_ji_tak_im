-------------------------------------------------------------------------------------
-- 宣告模組（Module）搜尋路徑
local project_path = "/Users/alanjui/workspace/lua/my_lua01/"
package.path = project_path .. "lua_modules/share/lua/5.4/?.lua;" .. package.path
package.path = project_path .. "lua_modules/share/lua/5.4/?/init.lua;" .. package.path
package.cpath = project_path .. "lua_modules/lib/lua/5.4/?.so;" .. package.cpath

-- 專案中引用的模組（Module）
package.path = project_path .. "?.lua;" .. package.path
package.path = project_path .. "?/init.lua;" .. package.path

local JSON = require("JSON")
local utils = require("utils")

-- local t = {
--   ["name1"] = "value100",
--   ["name2"] = "value101",
--   name3 = { 1, 3, 5, 7, 9 },
-- }
--
-- -- 將 table 變數轉換成 JSON 格式的字串
-- local encode = JSON:encode(t)
-- print(encode)
--
-- -- 將 JSON 格式的字串轉換成 table 變數
-- local decode = JSON:decode(encode)

local json_str = [[
{
  "name1": "value100",
  "name2": "value101",
  "name3": [1, 3, 5, 7, 9],
  "name4": null
}
]]

local table_from_json_str = JSON:decode(json_str)
-- print(table_from_json_str)
-- utils.DumpTable(table_from_json_str)
-- utils.PrintTable(table_from_json_str)
-- utils.PrintTableWithIndent(table_from_json_str, 2)
utils.inspect(table_from_json_str, 2)

print(string.format("table_from_json_str.name1 = %s", table_from_json_str.name1))
print(string.format("table_from_json_str.name2 = %s", table_from_json_str.name2))
print(string.format("table_from_json_str.name3 = %s", table_from_json_str.name3))
for i, v in ipairs(table_from_json_str.name3) do
  print(string.format("table_from_json_str.name3[%d] = %d", i, v))
end
print(string.format("table_from_json_str.name4 = %s", table_from_json_str.name4))
