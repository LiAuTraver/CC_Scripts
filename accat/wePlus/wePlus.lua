--- wePlus - WorldEdit++,
--- aims to fix the problems of WorldEdit
--- that not respecting block states when replacing blocks.

-- idk why this is needed, also does the `/` at the end.
package.path = package.path .. ";/?.lua"

local Variants = require("accat.wePlus.Variants")
local Specials = require("accat.wePlus.Specials")
local utils = require("accat.wePlus.utils")

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


  local allCombinations = utils.generateCombinations(variant_table)
  if #allCombinations == 0 then
    -- warn(
    --   "No variant combinations generated. " ..
    --   "Either the variant type is invalid or has no properties. " ..
    --   "In the latter case, use //replace directly.\n" ..
    --   "Aborting.")
    warn [[
No variant combinations generated.
Either the variant type is invalid or has no properties.
In the latter case, use //replace directly.
Aborting.
    ]]
  end

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

local function dumpOutput(outPath, outStrList)
  local outputFile, err = io.open(outPath, 'a')
  if not outputFile then
    warn("Failed to open output file: " ..
      err .. " Skipping log dump.")
    return
  end
  outputFile:write(string.format("wePlus: execute at time %s", os.date("%Y-%m-%d %H:%M:%S")) .. "\n\n\n\n")
  for _, line in ipairs(outStrList) do
    outputFile:write(line .. "\n")
  end
  outputFile:write("Logging finished.\n")
  outputFile:close()
end

local function main(args)
  -- like I said below, WorldEdit command return boolean false even on success
  local _, msgTable = commands.exec("worldedit version")
  -- hence we check the message instead
  if msgTable == nil or (#msgTable == 2 and msgTable[1]:match("Unknown or incomplete command, see below for error")) then
    error [[
WorldEdit is not installed or not functioning correctly.
Please make sure WorldEdit is functioning properly.
    ]]
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
      [[
 <pos1 x> <pos1 y> <pos1 z> <pos2 x> <pos2 y> <pos2 z>
--from=<variant1> --to=<variant2> --variant=<variant_type>
[--accept-continue]
]]
    )
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
    error(string.format("Unknown variant type: '%s'", tostring(variant_type)))
  end

  local allCommands = getCommands(pos1, pos2, from_variant, to_variant, variant_table, skipWarning)

  local output = {}

  for _, cmd in ipairs(allCommands) do
    output[#output + 1] = cmd
    local _, cmdMsg = commands.exec(cmd)
    -- WorldEdit command seems bugged and always return false even on success, hence we write down all output
    if cmdMsg ~= nil then
      for _, line in ipairs(cmdMsg) do
        output[#output + 1] = "   " .. line
      end
    else
      output[#output + 1] = "   (no output)"
    end
  end

  if not commands.testMode then
    dumpOutput(string.format("%s2%s_log.txt", from_variant, to_variant), output)
  end


  print(string.format("Total commands executed: %d", #allCommands))
  print("Operation completed.")
end



main({ ... })
