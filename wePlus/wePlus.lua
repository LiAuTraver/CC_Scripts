--- wePlus - WorldEdit++,
--- aims to fix the problems of WorldEdit
--- that not respecting block states when replacing blocks.


local Variants = require("wePlus.Variants")
local Specials = require("wePlus.Specials")
local utils = require("wePlus.utils")

local function getCommands(pos1, pos2, from_variant, to_variant, variant_table, skipWarning)
  ---@return string[]  -- always returns a table (may be empty)
  local totalBlockCount = (math.abs(pos2.x - pos1.x) + 1) *
      (math.abs(pos2.y - pos1.y) + 1) *
      (math.abs(pos2.z - pos1.z) + 1)
  if totalBlockCount > 65535 and not skipWarning then
    print(string.format(
      "Warning: You are about to replace %d of %s blocks with %s blocks of %s variant. Please confirm if you want to continue.",
      totalBlockCount, from_variant, to_variant,
      -- workaround to get the variant type name from the table
      string.upper(arg[9]:match("^%-%-variant=(.+)$")))
    )
    local response = io.read()
    if response:lower() ~= "y" and response:lower() ~= "yes" then
      print("Operation cancelled by user.")
      return {} -- ensure a table is always returned
    end
  end
  local allCommands = {}

  allCommands[#allCommands + 1] = "//world Flat_minecraft:overworld"
  allCommands[#allCommands + 1] = "//pos1 " .. pos1.x .. "," .. pos1.y .. "," .. pos1.z
  allCommands[#allCommands + 1] = "//pos2 " .. pos2.x .. "," .. pos2.y .. "," .. pos2.z


  local allCombinations = utils:generateCombinations(variant_table)

  for _, combo in ipairs(allCombinations) do
    local propStrings = {}
    -- Sort keys to ensure consistent order in command string
    local sortedKeys = {}
    for k in pairs(combo) do table.insert(sortedKeys, k) end
    table.sort(sortedKeys)

    for _, key in ipairs(sortedKeys) do
      table.insert(propStrings, string.format("%s=%s", key, combo[key]))
    end
    local fullPropString = table.concat(propStrings, ",")

    local command = string.format("//replace %s[%s] %s[%s]", from_variant, fullPropString, to_variant, fullPropString)
    table.insert(allCommands, command)
  end

  return allCommands
end

local function main(args)
  local we, _ = commands.exec("worldedit version")

  if not we then
    error(
      "WorldEdit is not installed or not functioning correctly.\nPlease make sure WorldEdit is functioning properly.")
  end

  local function sourcefile_location()
    return debug.getinfo(1, 'S').source:match("@(.+)$"):match("([^/\\]+)$")
  end

  if #args == 0 then
    print("No arguments provided. Use --help for usage information.")
    return
  end
  if #args == 1 and args[#args] == "--help" then
    print("Usage: lua " ..
      sourcefile_location() ..
      " <pos1 x> <pos1 y> <pos1 z> <pos2 x> <pos2 y> <pos2 z> " ..
      "--from=<variant1> --to=<variant2> --variant=<variant_type>")
    print("Example: lua " ..
      sourcefile_location() ..
      " 0 0 0 10 10 10 --from=oak_trapdoor --to=spruce_trapdoor --variant=trapdoor [--accept-continue]")
    return
  end
  if #args ~= 9 and #args ~= 10 then
    print("Invalid number of arguments. Use --help for usage information.")
    return
  end
  local skipWarning = false
  if #args == 10 then
    if args[#args] == "--accept-continue" then
      skipWarning = true
    else
      print("Invalid 10th argument. Use --help for usage information.")
      return
    end
  end

  local pos1 = {}
  pos1.x, pos1.y, pos1.z = utils:integer_or_error(args[1], args[2], args[3])
  local pos2 = {}
  pos2.x, pos2.y, pos2.z = utils:integer_or_error(args[4], args[5], args[6])

  local from_variant = args[7]:match("^%-%-from=(.+)$")
  local to_variant = args[8]:match("^%-%-to=(.+)$")
  local variant_type = args[9]:match("^%-%-variant=(.+)$")
  utils:validate_block(from_variant, to_variant)
  local variant_table = Variants[variant_type] or Specials[variant_type] or nil
  if variant_table == nil then
    error(string.format("Unknown variant type: '%s'", tostring(variant_type)), 2)
  end

  local allCommands = getCommands(pos1, pos2, from_variant, to_variant, variant_table, skipWarning)

  local output = {}

  for _, cmd in ipairs(allCommands) do
    output[#output + 1] = cmd
    local _, msg = commands.exec(cmd)
    -- WorldEdit command seems bugged and always return false even on success, hence we write down all output
    output[#output + 1] = "   " .. (msg[1] or "No message")
  end

  if not commands.testMode then
    local logFile = io.open(string.format("%s2%s_replog.txt",
      from_variant, to_variant,
      os.date("%Y%m%d_%H%M%S")), "w")

    if not logFile then
      warn("Failed to open log file for writing.")
    else
      for _, line in ipairs(output) do
        logFile:write(line .. "\n")
      end
      logFile:close()
    end
  end


  print(string.format("Total commands executed: %d", #allCommands))
  print("Operation completed.")
end



main({ ... })
