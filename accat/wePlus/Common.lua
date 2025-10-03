--- Utility functions for generating common variant tables.
local Common = {}

-- no need to add `local` again here:
-- (Error: Local function can only use identifiers as name.)
--- Returns a table of "x", "y", and "z" strings.
---@return table
---@nodiscard
function Common.axis()
  return { "x", "y", "z" }
end

--- Returns a table of "true" and "false" strings.
---@return table
---@nodiscard
function Common.boolean()
  return { "true", "false" }
end

--- Returns a table of numbers as strings from 0 to count - 1.
---@param count number? The number of entries to generate. Defaults to 16.
---@return table
---@nodiscard
function Common.numbers(count)
  count = count or 16
  if count <= 0 then
    error("Count must be a positive integer.")
  end

  -- we almost always want 16, so optimize that case
  if count == 16 then
    return { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15" }
  end

  local t = {}
  for i = 0, count - 1 do
    table.insert(t, tostring(i))
  end
  return t
end

--- Returns a table of cardinal direction strings.
--- ("north", "south", "east", "west")
--- @return table
--- @nodiscard
function Common.directions()
  return { "north", "south", "east", "west" }
end

return Common
