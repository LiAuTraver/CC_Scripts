--- Global variable. Only for testing purposes outside of Minecraft
commands = {}

commands.testMode = true

function commands.execAsync(command)
  print("Executing command asynchronously: " .. command)
  error("Currently, async commands not supported.")
  return true, { "Command executed successfully" } -- FIXME: this is wrong.
end

function commands.exec(command)
  print("Executing command: " .. command)
  return true, { "Command executed successfully" }
end

function commands.getBlockInfo()
  return nil
end

function commands.getBlockPosition()
  return 0, 0, 0
end
