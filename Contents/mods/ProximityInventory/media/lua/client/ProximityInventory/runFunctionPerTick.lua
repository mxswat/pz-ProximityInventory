local function runFunctionPerTick(processFunction, argTable)
  local nextArgIndex = 1

  local function runNextArg()
    if nextArgIndex <= #argTable then
      local currentArg = argTable[nextArgIndex]
      processFunction(currentArg)
      nextArgIndex = nextArgIndex + 1
    else
      Events.OnTick.Remove(runNextArg)
    end
  end

  Events.OnTick.Add(runNextArg)
end

return runFunctionPerTick
