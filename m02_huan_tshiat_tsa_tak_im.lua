-- 宣告模組（Module）搜尋路徑
local project_path = "/Users/alanjui/workspace/lua/my_lua01/"
package.path = project_path .. "lua_modules/share/lua/5.4/?.lua;" .. package.path
package.path = project_path .. "lua_modules/share/lua/5.4/?/init.lua;" .. package.path
package.cpath = project_path .. "lua_modules/lib/lua/5.4/?.so;" .. package.cpath

-- 專案中引用的模組（Module）
package.path = project_path .. "?.lua;" .. package.path
package.path = project_path .. "?/init.lua;" .. package.path

-- 載入 http 模組
local socket_url = require("socket.url")
local http_request = require("http.request")
local JSON = require("JSON")
local utils = require("utils")

local url = "http://localhost:8000/api/huan_tshiat_huat/"
-- (1) 自游標所在位置取得待查詢之漢字
-- local han_ji = vim.fn.expand "<cword>" or "在"
-- local han_ji = vim.fn.expand("<cword>") or "離"
-- (2) 自命令列取得欲查詢之漢字
local han_ji = arg[1] or "在"
-- local han_ji = arg[1] or "離"
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
utils.PrintTable(body_table, 2)

-- 解析響應資料為 Lua 表
local han_ji_dict = vim.fn.json_decode(body)

-- 將輸出內容寫入緩衝區
local lines = {
  "==============================================",
  "【查找漢字】：" .. han_ji,
}

if not han_ji_dict then
  table.insert(lines, "找不到反切讀音")
else
  if han_ji_dict["tak_im_list"] and #han_ji_dict["tak_im_list"] > 0 then
    for _, tak_im in ipairs(han_ji_dict["tak_im_list"]) do
      table.insert(lines, "----------------------------------------------")
      table.insert(lines, "【反切讀音】：" .. tak_im["huan_tshiat"])
      table.insert(lines, "【台羅拼音】：" .. tak_im["piau_im"]['tsuan_ji'])
      table.insert(lines, "【上字台羅】：" .. table.concat(tak_im["piau_im"]['siong_ji'], ""))
      table.insert(lines, "【下字台羅】：" .. table.concat(tak_im["piau_im"]['e_ji'], ""))
    end
  end
end

-- 創建新的緩衝區
local buf = vim.api.nvim_create_buf(false, true)


-- 將內容寫入緩衝區
for _, line in ipairs(lines) do
  -- 將每行字串添加到緩衝區
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
end

-- 將緩衝區顯示在新的窗口中
vim.api.nvim_command("vnew")
vim.api.nvim_command("buffer " .. buf)
