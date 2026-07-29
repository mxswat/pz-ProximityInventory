local ProximityInventory = require("ProximityInventory/ProximityInventory")

local old_ISInventoryPage_onBackpackRightMouseDown = ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage:onBackpackRightMouseDown(x, y)
  local container = self.inventory

  if container and container:getType() == "proxInv" then
    local page = self.parent and self.parent.parent
    local playerNum = (page and page.player) or 0

    local context = ISContextMenu.get(playerNum, getMouseX(), getMouseY())
    if not context then return end

    local forceSelectIcon = ProximityInventory.forceSelectIcon
    local highlightIcon = getTexture("media/textures/Item_LightBulb.png")

    local isForced = ProximityInventory.isForceSelected[playerNum]
    local forceText = isForced
        and getText("IGUI_ProxInv_Context_ForceSelectOn")
        or  getText("IGUI_ProxInv_Context_ForceSelectOff")
    local optForce = context:addOption(forceText, nil, function()
      ProximityInventory.isForceSelected[playerNum] = not ProximityInventory.isForceSelected[playerNum]
      ProximityInventory.manualContainerOverride[playerNum] = nil
      ISInventoryPage.dirtyUI()
    end)
    optForce.iconTexture = forceSelectIcon

    local isHighlight = ProximityInventory.isHighlightEnableOption:getValue()
    local highlightText = isHighlight
        and getText("IGUI_ProxInv_Context_HighlightOn")
        or  getText("IGUI_ProxInv_Context_HighlightOff")
    local optHighlight = context:addOption(highlightText, nil, function()
      ProximityInventory.isHighlightEnableOption:setValue(not ProximityInventory.isHighlightEnableOption:getValue())
      PZAPI.ModOptions:save()
      ISInventoryPage.dirtyUI()
    end)
    optHighlight.iconTexture = isHighlight and highlightIcon or nil

    return
  end

  return old_ISInventoryPage_onBackpackRightMouseDown(self, x, y)
end

local old_ISInventoryPage_onBackpackMouseDown = ISInventoryPage.onBackpackMouseDown
function ISInventoryPage:onBackpackMouseDown(button, x, y)
  local clickedContainer = button and button.inventory

  -- Shift+click on proxInv button: toggle force-select
  if clickedContainer and clickedContainer:getType() == "proxInv"
      and (isKeyDown(Keyboard.KEY_LSHIFT) or isKeyDown(Keyboard.KEY_RSHIFT)) then
    local playerNum = self.player or 0

    ProximityInventory.isForceSelected[playerNum] = not ProximityInventory.isForceSelected[playerNum]
    ProximityInventory.manualContainerOverride[playerNum] = nil

    local player = getSpecificPlayer(playerNum)
    local text = ProximityInventory.isForceSelected[playerNum]
        and getText("IGUI_ProxInv_Text_ForceSelectOn")
        or  getText("IGUI_ProxInv_Text_ForceSelectOff")
    HaloTextHelper.addText(player, text, "", HaloTextHelper.getColorWhite())

    ISInventoryPage.dirtyUI()
    return
  end

  -- Click on an individual container icon while force-select is active:
  -- set manualContainerOverride so OnRefreshEnd keeps it selected
  -- after the next refresh (instead of reverting to proxInv).
  if clickedContainer and clickedContainer:getType() ~= "proxInv" then
    local playerNum = self.player or 0
    if ProximityInventory.isForceSelected[playerNum] then
      ProximityInventory.manualContainerOverride[playerNum] = clickedContainer
    end
  end

  return old_ISInventoryPage_onBackpackMouseDown(self, button, x, y)
end

-- I know I kept some good separation between the mod code and the game code,
-- but just injecting the table is SOO much simpler, so I'll just inject it here
local old_ISInventoryPage_update = ISInventoryPage.update
function ISInventoryPage:update()
  old_ISInventoryPage_update(self)

  if not ProximityInventory.isEnabled:getValue() or self.onCharacter then return end

  self.coloredProxInventories = self.coloredProxInventories or {}

  for i = #self.coloredProxInventories, 1, -1 do
    local parent = self.coloredProxInventories[i]:getParent()
    if parent then
      parent:setHighlighted(self.player, false)
      parent:setOutlineHighlight(self.player, false)
      parent:setOutlineHlAttached(self.player, false)
    end
    self.coloredProxInventories[i] = nil
  end

  if not ProximityInventory.isHighlightEnableOption:getValue() or self.isCollapsed or self.inventory:getType() ~= "proxInv" then return end

  for i = 1, #self.backpacks do
    local container = self.backpacks[i].inventory
    local parent = container:getParent()
    if parent and (instanceof(parent, "IsoObject") or instanceof(parent, "IsoDeadBody")) then
      parent:setHighlighted(self.player, true, false)
      parent:setHighlightColor(self.player, getCore():getObjectHighlitedColor())
      self.coloredProxInventories[#self.coloredProxInventories + 1] = container
    end
  end
end
