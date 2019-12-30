local lfs = require("lfs")
local ltn12 = require("ltn12")

local fileUtil = {}

local dirSep = package.config:sub(1,1) -- handle Windows or Unix

function fileUtil.dirLookup(dir,list)
  list = list or {}	-- use provided list or create a new one

  for entry in lfs.dir(dir) do
    if entry ~= "." and entry ~= ".." then
      local ne = dir .. dirSep .. entry
      if lfs.attributes(ne).mode == 'directory' then
        fileUtil.dirLookup(ne,list)
      else
        table.insert(list,ne)
      end
    end
  end

  return list
end

function fileUtil.exists(name)
  if type(name)~="string" then return false end
  return os.rename(name,name) and true or false
end

function fileUtil.removeDir(dir)
  if not fileUtil.exists(dir) then
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
        fileUtil.removeDir(file_path)
      end
    end
  end
  lfs.rmdir(dir)
  print('remove dir',dir)
end

function fileUtil.copyFile(path_src, path_dst)
  ltn12.pump.all(
      ltn12.source.file(assert(io.open(path_src, "rb"))),
      ltn12.sink.file(assert(io.open(path_dst, "wb")))
  )
end

return fileUtil