-- Treats the proxInv virtual container as a "floor"-like container so the vanilla
-- loot window control bar (Take All / Take Same Type) shows up for it.
-- Without this, vanilla only renders those buttons for containers with type "floor".

-- CleanUI ships its own ISLootWindowContainerControls that already handles proxInv.
if getActivatedMods():contains("CleanUI") then
  print("[ProximityInventory] CleanUI detected -> skipping ProximityInventoryLootControls.lua")
  return
end

require "ISUI/LootWindow/ISLootWindowContainerControls"

-- proxInv is a virtual container with no parent object, so it falls in the same
-- branch vanilla reserves for "floor". Only intercept that case and delegate the
-- rest to the vanilla implementation.
local function IsProxInvContainer(container)
  return container and container:getType() == "proxInv"
end

local old_arrange = ISLootWindowContainerControls.arrange
function ISLootWindowContainerControls:arrange()
  local container = self:getDisplayedContainer()
  local object = self:getDisplayedObject()

  if object or not IsProxInvContainer(container) then
    return old_arrange(self)
  end

  for _, control in ipairs(self.controls) do
    control:setVisible(false)
    self:removeChild(control)
  end
  table.wipe(self.controls)

  local x, y = 1, 1
  local rowHgt = 0
  for _, handlerClass in ipairs(ISLootWindowContainerControls_FloorHandlerList) do
    local handler = self:checkHandler(handlerClass, nil, container)
    if handler:shouldBeVisible() then
      local control = handler:getControl()
      if (x > 0) and (x + control:getWidth() > self.width) then
        x = 1
        y = y + rowHgt
        rowHgt = 0
      end
      control:setX(x)
      control:setY(y)
      control:setVisible(true)
      self:addChild(control)
      table.insert(self.controls, control)
      x = control:getRight() + 10
      rowHgt = math.max(rowHgt, control:getHeight())
    end
  end
  self:setHeight(y + rowHgt + 1)

  if #self.controls > 0 then
    self:setX(0)
    self:setY(self.lootWindow.resizeWidget.y - self.height)
    self:setWidth(self.lootWindow:getWidth())
    self:setVisible(true)
    self:fixMouseOverButton()
  else
    self:setVisible(false)
    self:setHeight(0)
  end
end

local old_handleJoypadContextMenu = ISLootWindowContainerControls.handleJoypadContextMenu
function ISLootWindowContainerControls:handleJoypadContextMenu(context)
  local container = self:getDisplayedContainer()
  local object = self:getDisplayedObject()

  if object or not IsProxInvContainer(container) then
    return old_handleJoypadContextMenu(self, context)
  end

  for _, handlerClass in ipairs(ISLootWindowContainerControls_FloorHandlerList) do
    local handler = self:checkHandler(handlerClass, nil, container)
    if handler:shouldBeVisible() then
      handler:handleJoypadContextMenu(context)
    end
  end
end
