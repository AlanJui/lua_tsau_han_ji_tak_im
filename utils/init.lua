local json = require("dkjson")

local M = {}

function M.ExecProcess(command)
  local handle = io.popen(command)
  local result = handle and handle:read("*all")
  if handle then
    handle:close()
  end
  return result
end

function M.isJSON(output)
  local ok, jsonString = pcall(hs.json.decode, output)
  return ok, jsonString
end

function M.convert_args_string(str)
  local args = {}
  for word in string.gmatch(str, "%S+") do
    table.insert(args, word)
  end
  return args
end

function M.convertTableToString(tbl)
  return table.concat(tbl, " ")
end

local function isList(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then
      return false
    end
  end
  return true
end

function M.find_value_in_list(value_to_be_found, table_list)
  for key, val in pairs(table_list) do
    if tonumber(val) == value_to_be_found then
      return key
    end
  end
  return nil
end

function M.countItemsInTable(tbl)
  if isList(tbl) then
    return #tbl
  end

  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

function M.ParseJsonToTable(jsonString)
  local jsonArray = hs.json.decode(jsonString)
  local luaTable = {}

  for _, jsonObj in ipairs(jsonArray) do
    table.insert(luaTable, {
      id = jsonObj.id,
      app = jsonObj.app,
      title = jsonObj.title,
    })
  end

  return luaTable
end

function M.TableConcat(t1, t2)
  for i = 1, #t2, 1 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

function M.JoinTwoTable(tbl1, tbl2)
  local new_tbl = {}
  for k, v in pairs(tbl1) do
    new_tbl[k] = v
  end
  for _, v in pairs(tbl2) do
    table.insert(new_tbl, v)
  end

  return new_tbl
end

local function print_table(node)
  local cache, stack, output = {}, {}, {}
  local depth = 1
  local output_str = "{\n"

  while true do
    local size = 0
    for k, v in pairs(node) do
      size = size + 1
    end

    local cur_index = 1
    for k, v in pairs(node) do
      if (cache[node] == nil) or (cur_index >= cache[node]) then
        if string.find(output_str, "}", output_str:len()) then
          output_str = output_str .. ",\n"
        elseif not (string.find(output_str, "\n", output_str:len())) then
          output_str = output_str .. "\n"
        end

        -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
        table.insert(output, output_str)
        output_str = ""

        local key
        if type(k) == "number" or type(k) == "boolean" then
          key = "[" .. tostring(k) .. "]"
        else
          key = "['" .. tostring(k) .. "']"
        end

        if type(v) == "number" or type(v) == "boolean" then
          output_str = output_str .. string.rep("\t", depth) .. key .. " = " .. tostring(v)
        elseif type(v) == "table" then
          output_str = output_str .. string.rep("\t", depth) .. key .. " = {\n"
          table.insert(stack, node)
          table.insert(stack, v)
          cache[node] = cur_index + 1
          break
        else
          output_str = output_str .. string.rep("\t", depth) .. key .. " = '" .. tostring(v) .. "'"
        end

        if cur_index == size then
          output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}"
        else
          output_str = output_str .. ","
        end
      else
        -- close the table
        if cur_index == size then
          output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}"
        end
      end

      cur_index = cur_index + 1
    end

    if size == 0 then
      output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}"
    end

    if #stack > 0 then
      node = stack[#stack]
      stack[#stack] = nil
      depth = cache[node] == nil and depth + 1 or depth - 1
    else
      break
    end
  end

  -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
  table.insert(output, output_str)
  output_str = table.concat(output)

  print(output_str)
end

function M.PrintTable(tbl)
  print_table(tbl)
end

local function tprint(tbl, indent)
  if not indent then
    indent = 0
  end
  local toprint = string.rep(" ", indent) .. "{\n"
  indent = indent + 2
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if type(k) == "number" then
      toprint = toprint .. "[" .. k .. "] = "
    elseif type(k) == "string" then
      toprint = toprint .. k .. "= "
    end
    if type(v) == "number" then
      toprint = toprint .. v .. ",\n"
    elseif type(v) == "string" then
      toprint = toprint .. '"' .. v .. '",\n'
    elseif type(v) == "table" then
      toprint = toprint .. tprint(v, indent + 2) .. ",\n"
    else
      toprint = toprint .. '"' .. tostring(v) .. '",\n'
    end
  end
  toprint = toprint .. string.rep(" ", indent - 2) .. "}"
  return toprint
end

function M.PrintTableWithIndent(tbl, indent)
  tprint(tbl, indent)
end

function M.inspect(o, indent)
  if indent == nil then
    indent = 0
  end
  local indent_str = string.rep("    ", indent)
  local output_it = function(str)
    print(indent_str .. str)
  end

  local length = 0

  local fu = function(k, v)
    length = length + 1
    if type(v) == "userdata" or type(v) == "table" then
      output_it(indent_str .. "[" .. k .. "]")
      M.inspect(v, indent + 1)
    else
      output_it(indent_str .. "[" .. k .. "] " .. tostring(v))
    end
  end

  local loop_pairs = function()
    for k, v in pairs(o) do
      fu(k, v)
    end
  end

  local loop_metatable_pairs = function()
    for k, v in pairs(getmetatable(o)) do
      fu(k, v)
    end
  end

  if not pcall(loop_pairs) and not pcall(loop_metatable_pairs) then
    output_it(indent_str .. "[[??]]")
  else
    if length == 0 then
      output_it(indent_str .. "{}")
    end
  end
end

function M.DumpTableAsTree(node)
  local cache, stack, output = {}, {}, {}
  local depth = 1
  local output_str = "{\n"

  while true do
    local size = 0
    ---@diagnostic disable-next-line: unused-local
    for k, v in pairs(node) do -- luacheck: ignore
      size = size + 1
    end

    local cur_index = 1
    for k, v in pairs(node) do
      if (cache[node] == nil) or (cur_index >= cache[node]) then
        if string.find(output_str, "}", output_str:len()) then
          output_str = output_str .. ",\n"
        elseif not (string.find(output_str, "\n", output_str:len())) then
          output_str = output_str .. "\n"
        end

        -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
        table.insert(output, output_str)
        output_str = ""

        local key
        if type(k) == "number" or type(k) == "boolean" then
          key = "[" .. tostring(k) .. "]"
        else
          key = "['" .. tostring(k) .. "']"
        end

        if type(v) == "number" or type(v) == "boolean" then
          output_str = output_str .. string.rep("\t", depth) .. key .. " = " .. tostring(v)
        elseif type(v) == "table" then
          output_str = output_str .. string.rep("\t", depth) .. key .. " = {\n"
          table.insert(stack, node)
          table.insert(stack, v)
          cache[node] = cur_index + 1
          break
        else
          output_str = output_str .. string.rep("\t", depth) .. key .. " = '" .. tostring(v) .. "'"
        end

        if cur_index == size then
          output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}"
        else
          output_str = output_str .. ","
        end
      else
        -- close the table
        if cur_index == size then
          output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}"
        end
      end

      cur_index = cur_index + 1
    end

    if size == 0 then
      output_str = output_str .. "\n" .. string.rep("\t", depth - 1) .. "}"
    end

    if #stack > 0 then
      node = stack[#stack]
      stack[#stack] = nil
      depth = cache[node] == nil and depth + 1 or depth - 1
    else
      break
    end
  end

  -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
  table.insert(output, output_str)
  output_str = table.concat(output)

  print(output_str)
end

function M.DumpTable(table)
  for k, v in pairs(table) do
    print("key = ", k, "    value = ", tostring(v))
  end
end

function M.file_exists(filePath)
  local f = io.open(filePath, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function M.IsFileExist(path)
  return M.file_exists(path)
end

function M.IsEmpty(str)
  return str == nil or str == ""
end

-----------------------------------------------------------------------------
-- Exampe: JoinPaths("a", "b", "c") => "a/b/c"
-----------------------------------------------------------------------------
PathSep = "/"
function M.JoinPaths(...)
  local result = table.concat({ ... }, PathSep)
  return result
end

function M.IsGitDir()
  return os.execute("git rev-parse --is-inside-work-tree >> /dev/null 2>&1")
end

function M.GetHomeDir()
  return os.getenv("HOME")
end

function M.Safe_Require(module)
  local ok, result = pcall(require, module)
  if not ok then
    -- vim.notify(string.format("Plugin not installed: %s", module), vim.log.levels.ERROR)
    vim.notify(string.format("Plugin not installed: %s", module), vim.log.levels.WARN)
    return ok
  end
  return result
end

-- 1 秒 = 1000 毫秒（milliseconds，ms）
function M.Pause(n)
  hs.timer.usleep(tonumber(n) * 100000) -- 等待 N * 100 毫秒(0.1秒)
end

return M
