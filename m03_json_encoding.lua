local json = require("dkjson")

local tbl = {
  animals = { "dog", "cat", "aardvark" },
  instruments = { "violin", "trombone", "theremin" },
  bugs = json.null,
  trees = nil
}

-- local str = json.encode(tbl, { indent = true })
local str = json.encode(tbl, { indent = false })

print(str)
