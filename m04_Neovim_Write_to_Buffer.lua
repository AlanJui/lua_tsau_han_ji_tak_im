-- 宣告模組（Module）搜尋路徑
local project_path = "/Users/alanjui/workspace/lua/my_lua01/"
package.path = project_path .. "lua_modules/share/lua/5.4/?.lua;" .. package.path
package.path = project_path .. "lua_modules/share/lua/5.4/?/init.lua;" .. package.path
package.cpath = project_path .. "lua_modules/lib/lua/5.4/?.so;" .. package.cpath

-- 專案中引用的模組（Module）
package.path = project_path .. "?.lua;" .. package.path
package.path = project_path .. "?/init.lua;" .. package.path

-- 引入需要使用的函式庫
-- local socket_url = require("socket.url")
-- local http_request = require("http.request")
-- local JSON = require("JSON")
local utils = require("utils")

-- 程式啟始點
local han_ji = "在"

-- 將 JSON 格式的字串轉換成 table 變數
local json_str = [[
{
    "han_ji": "在",
    "tak_im_list": [
        {
            "huan_tshiat": "昨宰",
            "piau_im": {
                "tsuan_ji": "tsai6",
                "siong_ji": [
                    "ts",
                    "ok",
                    "8"
                ],
                "e_ji": [
                    "ts",
                    "ai",
                    "2"
                ]
            },
            "un_su": "廣韻",
            "siann_tiau": "上聲",
            "siann_bu": "海",
            "un_bu": "在"
        },
        {
            "huan_tshiat": "昨代",
            "piau_im": {
                "tsuan_ji": "tsai7",
                "siong_ji": [
                    "ts",
                    "ok",
                    "8"
                ],
                "e_ji": [
                    "t",
                    "ai",
                    "7"
                ]
            },
            "un_su": "廣韻",
            "siann_tiau": "去聲",
            "siann_bu": "代",
            "un_bu": "載"
        }
    ]
}
]]

-- 將 JSON 格式的字串轉換成 table 變數
-- local han_ji_dict = JSON:decode(json_str)
local han_ji_dict = vim.fn.json_decode(json_str)
-- utils.PrintTable(han_ji_dict, 2)

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
-- utils.PrintTable(lines, 2)

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
