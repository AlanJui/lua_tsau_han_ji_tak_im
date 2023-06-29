-------------------------------------------------------------------------------------
-- 確認模組已安裝及搜尋路徑已設定
-- luarocks show lpeg
-- luarocks path
-- echo $LUA_CPATH
-------------------------------------------------------------------------------------
-- 宣告模組（Module）搜尋路徑
local project_path = "/Users/alanjui/workspace/lua/my_lua01/"
package.path = project_path .. "lua_modules/share/lua/5.4/?.lua;" .. package.path
package.path = project_path .. "lua_modules/share/lua/5.4/?/init.lua;" .. package.path
package.cpath = project_path .. "lua_modules/lib/lua/5.4/?.so;" .. package.cpath

local socket_url = require("socket.url")
local http_request = require("http.request")
local url = "http://localhost:8000/api/huan_tshiat_huat/"
local han_ji = "在"
local encoded_han_ji = socket_url.escape(han_ji)
local query = "?han_ji=" .. encoded_han_ji
local full_url = url .. query

local headers, stream = http_request.new_from_uri(full_url):go()
local body = stream:get_body_as_string()

if headers:get(":status") ~= "200" then
	error(body)
end

print(body)
