print(package.path)

local function get_script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*[/\\])")
end

print()
print("Script path: " .. get_script_path())
