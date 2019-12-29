local lfs = require("lfs")

local util = {}

local dirSep = package.config:sub(1,1) -- handle Windows or Unix

function util.dirLookup(dir,list)
  list = list or {}	-- use provided list or create a new one

  for entry in lfs.dir(dir) do
    if entry ~= "." and entry ~= ".." then
      local ne = dir .. dirSep .. entry
      if lfs.attributes(ne).mode == 'directory' then
        util.dirLookup(ne,list)
      else
        table.insert(list,ne)
      end
    end
  end

  return list
end

local function exists(name)
  if type(name)~="string" then return false end
  return os.rename(name,name) and true or false
end

function util.removeDir(dir)
  if not exists(dir) then
    return
  end
  for file in lfs.dir(dir) do
    local file_path = dir .. dirSep .. file
    if file ~= "." and file ~= ".." then
      if lfs.attributes(file_path, 'mode') == 'file' then
        os.remove(file_path)
        print('remove file',file_path)
      elseif lfs.attributes(file_path, 'mode') == 'directory' then
        print('dir', file_path)
        util.removeDir(file_path)
      end
    end
  end
  lfs.rmdir(dir)
  print('remove dir',dir)
end

function util.endsWith(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

---@param str string @the string to template, variables should be written as {{ var }}
---@param data table<string, string>
---@return string the templated string
function util.templateString(str, data)
  local result = str
  for k, v in pairs(data) do
    result = result:gsub("{{ ?" ..k.." ?}}", v)
  end
  return result
end

return util