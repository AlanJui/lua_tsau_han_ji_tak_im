-------------------------------------------------------------------------------------
-- 確認模組已安裝及搜尋路徑已設定
-- luarocks show lpeg
-- luarocks path
-- echo $LUA_CPATH
-------------------------------------------------------------------------------------
-- 宣告模組（Module）搜尋路徑
-- package.path = "/Users/alanjui/.luarocks/share/lua/5.3/?.lua;/Users/alanjui/.luarocks/share/lua/5.3/?/init.lua;" .. package.path
-- package.cpath = "/Users/alanjui/.luarocks/lib/lua/5.3/?.so;" .. package.cpath
--
-- package.path = "/Users/alanjui/workspace/lua/my_libs_http/lua_modules/share/lua/5.3/?.lua;" .. package.path
-- package.path = "/Users/alanjui/workspace/lua/my_libs_http/lua_modules/share/lua/5.3/?/init.lua;" .. package.path
-- package.cpath = "/Users/alanjui/workspace/lua/my_libs_http/lua_modules/lib/lua/5.3/?.so;" .. package.cpath

-- local http_request = require "http.request"
-- local han_ji = "在"
-- local han_ji = "%E5%9C%A8"
-- local url = "http://localhost:8000/api/huan_tshiat_huat/?han_ji=" .. han_ji
-- local body = stream:get_body_as_string()
-- local headers, stream = http_request.new_from_uri(url):go()

local socket_url = require "socket.url"
local http_request = require "http.request"
local url = "http://localhost:8000/api/huan_tshiat_huat/"
local han_ji = "在"
local encoded_han_ji = socket_url.escape(han_ji)
local query = "?han_ji=" .. encoded_han_ji
local full_url = url .. query

local headers, stream = http_request.new_from_uri(full_url):go()
local body = stream:get_body_as_string()

if headers:get ":status" ~= "200" then error(body) end

print(body)
