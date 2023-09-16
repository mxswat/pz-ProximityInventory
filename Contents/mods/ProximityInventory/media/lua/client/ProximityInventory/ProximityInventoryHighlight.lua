function ISInventoryPage:removeHighlightProxInvContainers()
  self.highlightedContainers = self.highlightedContainers or {}

  for _, container in ipairs(self.highlightedContainers) do
    if container:getParent() then
      container:getParent():setHighlighted(false)
      container:getParent():setOutlineHighlight(false);
    end
  end

  table.wipe(self.highlightedContainers)
end

function ISInventoryPage:highlightProxInvContainers()
  for i = 1, #self.backpacks do
    local button = self.backpacks[i]
    if button ~= self.proxInvButton then
      local container = button.inventory
      local containerParent = button.inventory:getParent()
      local isIsoObject = instanceof(containerParent, "IsoObject")
      local isIsoDeadBody = instanceof(containerParent, "IsoDeadBody")
      if isIsoObject or isIsoDeadBody then
        containerParent:setHighlighted(true, false)
        containerParent:setHighlightColor(getCore():getObjectHighlitedColor())
        if getCore():getOptionDoContainerOutline() then
          containerParent:setOutlineHighlight(true);
          containerParent:setOutlineHighlightCol(1, 1, 1, 1);
        end
        table.insert(self.highlightedContainers, container)
      end
    end
  end
end

local old_ISInventoryPage_update = ISInventoryPage.update
function ISInventoryPage:update()
  self:removeHighlightProxInvContainers();

  if not ProxInv.Options.enableHighlight
      or self.isCollapsed
      or self.onCharacter
      or self.inventory:getType() ~= "proxinv"
  then
    return old_ISInventoryPage_update(self)
  end

  self:highlightProxInvContainers()

  return old_ISInventoryPage_update(self)
end
