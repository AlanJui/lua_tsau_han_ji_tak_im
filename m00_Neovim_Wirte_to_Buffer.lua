-- 創建新的緩衝區
local buf = vim.api.nvim_create_buf(false, true)

-- 將內容拆分為單獨的行
local lines = {
  '{',
  '    "han_ji": "在",',
  '    "tak_im_list": [',
  '        {',
  '            "huan_tshiat": "昨宰",',
  '            "piau_im": {',
  '                "tsuan_ji": "tsai6",',
  '                "siong_ji": [',
  '                    "ts",',
  '                    "ok",',
  '                    "8"',
  '                ],',
  '                "e_ji": [',
  '                    "ts",',
  '                    "ai",',
  '                    "2"',
  '                ]',
  '            },',
  '            "un_su": "廣韻",',
  '            "siann_tiau": "上聲",',
  '            "siann_bu": "海",',
  '            "un_bu": "在"',
  '        },',
  '        {',
  '            "huan_tshiat": "昨代",',
  '            "piau_im": {',
  '                "tsuan_ji": "tsai7",',
  '                "siong_ji": [',
  '                    "ts",',
  '                    "ok",',
  '                    "8"',
  '                ],',
  '                "e_ji": [',
  '                    "t",',
  '                    "ai",',
  '                    "7"',
  '                ]',
  '            },',
  '            "un_su": "廣韻",',
  '            "siann_tiau": "去聲",',
  '            "siann_bu": "代",',
  '            "un_bu": "載"',
  '        }',
  '    ]',
  '}'
}

-- 將內容寫入緩衝區
for _, line in ipairs(lines) do
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
end

-- 將緩衝區顯示在新的窗口中
vim.api.nvim_command("vnew")
vim.api.nvim_command("buffer " .. buf)
