local utils = {}

-- for testing outside of Minecraft
if commands == nil then
  ---@diagnostic disable-next-line: unused-local
  local commands = require("accat.stub.commands")
  print("Running in test mode with stub commands.")
end

--- Convert one or more values to integers. For a single argument returns integer|nil.
--- For multiple arguments returns each converted integer (or nil) as multiple return values.
---@param ... any
---@return integer? ...  Returns one integer or nil if one arg; multiple integers/nils if many.
function utils:tointeger(...)
  local n = select('#', ...)
  if n == 1 then
    local value = ...
    local number = tonumber(value)
    if number == nil or math.floor(number) ~= number then
      return nil
    end
    return number
  end
  local results = {}
  for i = 1, n do
    local v = select(i, ...)
    local num = tonumber(v)
    if num ~= nil and math.floor(num) == num then
      results[i] = num
    else
      results[i] = nil
    end
  end
  return table.unpack(results, 1, n)
end

--- Convert one or more values to integers, throwing an error if any conversion fails.
--- @param ... any  Values to convert.
--- @return integer ...  All converted integers (multiple return values if multiple args passed).
function utils:integer_or_error(...)
  local args = { ... } -- capture all arguments into a table
  local n = #args
  if n == 0 then
    error("Expected at least one value")
  end
  local results = {}
  for i = 1, n do
    local value = args[i] -- get the i-th argument from the table
    local integer = self:tointeger(value)
    if integer == nil then
      error(string.format("Expected an integer at argument #%d, got '%s'", i, tostring(value)))
    end
    results[i] = integer
  end
  return table.unpack(results, 1, n)
end

--- Verify a condition and throw an error if it is false.
---@param condition any
---@param message any
---@param ... any
---@return nil
function utils.verify(condition, message, ...)
  if not condition then
    error(string.format(message, ...))
  end
end

utils.world_height = 319
utils.current_location = {}
utils.current_location.x, utils.current_location.y, utils.current_location.z = commands.getBlockPosition()
utils.default_test_coord = { x = utils.current_location.x, y = utils.world_height, z = utils.current_location.z }

function utils:validate_block(...)
  for _, blockId in ipairs({ ... }) do
    local success, msgTable = commands.exec(string.format("execute run setblock %d %d %d %s",
      self.default_test_coord.x,
      self.default_test_coord.y,
      self.default_test_coord.z, blockId))

    if not success then
      local msg = ""
      if msgTable ~= nil then
        for _, line in ipairs(msgTable) do
          msg = msg .. line .. " "
        end
      else
        msg = "(no message)"
      end
      error(string.format("An error occurred while validating block '%s':\n%s", tostring(blockId), msg))
    end

    commands.exec(string.format("setblock %d %d %d air",
      self.default_test_coord.x,
      self.default_test_coord.y,
      self.default_test_coord.z))
  end
end

--- Helper function to generate all combinations of properties. The function uses somewhat
---   called `reflection` in some typed languages and is AI-generated. Use at your own risk.
--- @param properties table A table where keys are property names and values are tables of possible values.
--- @return table tables A list of tables, each representing a unique combination of properties.
function utils.generateCombinations(properties)
  local combinations = { {} } -- Start with one empty combination table
  for propName, propValues in pairs(properties) do
    local newCombinations = {}
    for _, existingCombo in ipairs(combinations) do
      for _, value in ipairs(propValues) do
        local newCombo = {}
        -- Copy existing combination
        for k, v in pairs(existingCombo) do
          newCombo[k] = v
        end
        -- Add the new property value
        newCombo[propName] = value
        table.insert(newCombinations, newCombo)
      end
    end
    combinations = newCombinations
  end
  return combinations
end

return utils
