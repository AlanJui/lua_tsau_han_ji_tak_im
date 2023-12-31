-- 宣告模組（Module）搜尋路徑
local project_path = "/Users/alanjui/workspace/lua/my_lua01/"
package.path = project_path .. "lua_modules/share/lua/5.4/?.lua;" .. package.path
package.path = project_path .. "lua_modules/share/lua/5.4/?/init.lua;" .. package.path
package.cpath = project_path .. "lua_modules/lib/lua/5.4/?.so;" .. package.cpath

-- 專案中引用的模組（Module）
package.path = project_path .. "?.lua;" .. package.path
package.path = project_path .. "?/init.lua;" .. package.path

local socket_url = require("socket.url")
local http_request = require("http.request")
local JSON = require("JSON")
local utils = require("utils")

local url = "http://localhost:8000/api/huan_tshiat_huat/"
local han_ji = arg[1] or "在"
local encoded_han_ji = socket_url.escape(han_ji)
local query = "?han_ji=" .. encoded_han_ji
local full_url = url .. query

local headers, stream = http_request.new_from_uri(full_url):go()
local body = stream:get_body_as_string()

if headers:get(":status") ~= "200" then
	error(body)
end

-- 將 JSON 格式的字串轉換成 table 變數
local body_table = JSON:decode(body)
-- print(body)
-- utils.PrintTable(body_table, 2)

print("==================================================")
print(string.format("查找漢字 = %s", body_table.han_ji))
if body_table.tak_im_list then
	for i, v in ipairs(body_table.tak_im_list) do
		print("--------------------------------------------------")
		print(string.format("反切讀音 = %s", v.huan_tshiat))
		print(string.format("台羅拼音 = %s", v.piau_im))
		print(string.format("聲母 = %s", v.siann_bu))
		print(string.format("韻母 = %s", v.un_bu))
		print(string.format("聲調 = %s", v.siann_tiau))
		print(string.format("韻書 = %s", v.un_bu))
	end
else
	print(string.format("〖 %s 〗此字找不到反切讀音！", body_table.han_ji))
end
print("==================================================")
print()
