ProxInv = {}

ProxInv.containerType = "proxinv"

ProxInv.icons = {
  enabled = getTexture("media/ui/ProximityInventory.png"),
  disabled = getTexture("media/ui/ProximityInventory_Disabled.png"),
  corpse = getTexture("media/ui/ProximityInventory_Corpse.png")
}

ProxInv.zombieContainerTypes = {
  inventoryfemale = true,
  inventorymale = true,
}

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
  enableProxInv = true,
  enableHighlight = true,
  alwaysAsFirst = true,
}

if not ModOptions then
  return
end

if ModOptions.getInstance then
  local settings = ModOptions:getInstance(ProxInv.Options, "ProxInv", "Proximity Inventory")

  settings.names = {
    enableProxInv = "IGUI_ProxInv_Enable",
    enableHighlight = "IGUI_ProxInv_EnableHighlight",
    alwaysAsFirst = "IGUI_ProxInv_AlwaysAsFirst",
  }
end

ProxInv.isForceSelected = false

local KEY_ForceSelected = {
  name = "ProxInv_Force_Selected",
  key = Keyboard.KEY_NUMPAD0,
}

if ModOptions.AddKeyBinding then
  ModOptions:AddKeyBinding("[ProximityInventory]", KEY_ForceSelected)
end

local function OnKeyPressed(keynum)
  local player = getSpecificPlayer(0)
  if not player then
    return
  end

  if keynum == KEY_ForceSelected.key then
    ProxInv.isForceSelected = not ProxInv.isForceSelected
    local text = getText("IGUI_ProxInv_Force_Selected_" .. (ProxInv.isForceSelected and 'ON' or 'OFF'))
    HaloTextHelper.addText(player, text, HaloTextHelper.getColorWhite())
    ISInventoryPage.dirtyUI()
    return
  end
end

Events.OnKeyPressed.Add(OnKeyPressed)
