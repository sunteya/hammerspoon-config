
local hack = {}

function hack.require(name, file, pattern, addons)
  local content = io.open(file, "r"):read("*a")
  local hackContent = string.gsub(content, pattern, addons)
  local init = load(hackContent)
  local result = init()
  package.loaded[name] = result
  
  return result
end

return hack
