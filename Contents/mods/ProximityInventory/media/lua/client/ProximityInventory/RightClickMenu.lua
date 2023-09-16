local old_ISInventoryPage_onBackpackRightMouseDown = ISInventoryPage.onBackpackRightMouseDown
function ISInventoryPage:onBackpackRightMouseDown(x, y)
  local result = old_ISInventoryPage_onBackpackRightMouseDown(self, x, y)
  local page = self.parent
  local container = self.inventory

  if container:getType() ~= ProxInv.containerType then
    return result
  end

  local context = ISContextMenu.get(page.player, getMouseX(), getMouseY())

  local toggleText = ProxInv.Options.enableProxInv and getText("IGUI_ProxInv_Toggle_OFF") or getText("IGUI_ProxInv_Toggle_ON")
  local optToggle = context:addOption(toggleText, nil, function ()
    ProxInv.Options.enableProxInv = not ProxInv.Options.enableProxInv
    ISInventoryPage.dirtyUI()
  end)
  optToggle.iconTexture = ProxInv.Options.enableProxInv and ProxInv.icons.disabled or ProxInv.icons.enabled;

  local forceSelectedText = ProxInv.isForceSelected and getText("IGUI_ProxInv_Toggle_Force_Selected_OFF") or getText("IGUI_ProxInv_Toggle_Force_Selected_ON")
  local optForce = context:addOption(forceSelectedText, nil, function()
    ProxInv.isForceSelected = not ProxInv.isForceSelected
    ISInventoryPage.dirtyUI()
  end)
  optForce.iconTexture = getTexture("media/ui/Panel_Icon_Pin.png");

  return result
end
