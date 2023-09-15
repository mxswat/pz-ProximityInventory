ProxInv = {}

function ProxInv.print(...)
  if not isDebugEnabled() then
    return
  end
  local arguments = { ... }
  local printResult = ''
  for _, v in ipairs(arguments) do
    printResult = printResult .. tostring(v or 'nil') .. " "
  end
  print('ProxInv:' .. printResult)
end

ProxInv.Options = {
  enableHighlight = true,
}

if ModOptions and ModOptions.getInstance then
  local settings = ModOptions:getInstance(ProxInv.Options, "ProxInv", "Proximity Inventory")

  settings.names = {
    enableHighlight = "IGUI_ProxInv_EnableHighlight",
  }
end