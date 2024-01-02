local ProximityInventory = require("ProximityInventory/ProximityInventory")

local old_ISInventoryPage_onBackpackRightMouseDown = ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage:onBackpackRightMouseDown(x, y)
  local result = old_ISInventoryPage_onBackpackRightMouseDown(self, x, y)
  local page = self.parent
  local container = self.inventory

  if container:getType() ~= "proxInv" then
    return result
  end

  local context = ISContextMenu.get(page.player, getMouseX(), getMouseY())

  local toggleText = ProximityInventory.isToggled and "OFF" or "ON"
  local optToggle = context:addOption("Toggle " .. toggleText, nil, function()
    ProximityInventory.isToggled = not ProximityInventory.isToggled
    ProximityInventory.refreshUI()
  end)
  optToggle.iconTexture = ProximityInventory.inventoryIcon;

  local forceSelectedText = ProximityInventory.isForceSelected and "Disable" or "Enable"
  local optForce = context:addOption(forceSelectedText .. " Force Selected", nil, function()
    ProximityInventory.isForceSelected = not ProximityInventory.isForceSelected
    ProximityInventory.refreshUI()
  end)
  optForce.iconTexture = getTexture("media/ui/Panel_Icon_Pin.png");

  local highlightText = ProximityInventory.isHighlightEnable and "Disable" or "Enable"
  local optForce = context:addOption(highlightText .. " Highlight", nil, function()
    ProximityInventory.isHighlightEnable = not ProximityInventory.isHighlightEnable
    ProximityInventory.refreshUI()
  end)

  return result
end
