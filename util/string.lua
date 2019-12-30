local stringUtil = {}

function stringUtil.firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

function stringUtil.endsWith(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

---@param str string @the string to template, variables should be written as {{ var }}
---@param data table<string, string>
---@return string the templated string
function stringUtil.templateString(str, data)
  local result = str
  for k, v in pairs(data) do
    result = result:gsub("{{ ?" ..k.." ?}}", v)
  end
  return result
end

return stringUtil