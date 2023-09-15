local proxInvIcon = getTexture("media/ui/ProximityInventory.png")

function ISInventoryPage.GetProxInvContainer(playerNum)
  if ISInventoryPage.proxInvContainer == nil then
    ISInventoryPage.proxInvContainer = {}
  end
  if ISInventoryPage.proxInvContainer[playerNum + 1] == nil then
    ISInventoryPage.proxInvContainer[playerNum + 1] = ItemContainer.new("proxinv", nil, nil, 10, 10)
    ISInventoryPage.proxInvContainer[playerNum + 1]:setExplored(true)
  end
  return ISInventoryPage.proxInvContainer[playerNum + 1]
end

function ISInventoryPage:addProxInvButton()
  local proxInvContainer = ISInventoryPage.GetProxInvContainer(self.player)
  proxInvContainer:removeItemsFromProcessItems()
  proxInvContainer:clear()

  local title = getText("IGUI_ProxInventoryButton")
  self.proxInvButton = self:addContainerButton(proxInvContainer, proxInvIcon, title, title)
  self.proxInvButton.capacity = 0
  self.proxInvButton:setY(self:titleBarHeight() - 1)
  return self.proxInvButton
end

function ISInventoryPage:isContainerLocked(container, player)
  local playerObj = getSpecificPlayer(player)
  local object = container:getParent()
  return object and instanceof(object, "IsoThumpable") and object:isLockedToCharacter(playerObj)
end

function ISInventoryPage:injectProxInvButton()
  for i = 1, #self.backpacks do
    local button = self.backpacks[i]
    local container = self.backpacks[i].inventory
    local isLocked = self:isContainerLocked(container, self.player)
    if button ~= self.proxInvButton then
      -- button:setY(button:getY() + button:getHeight()) -- Patch all the buttons Y position
      if not isLocked  then
        local items = container:getItems()
        self.proxInvButton.inventory:getItems():addAll(items)
      end
    end
  end
end

Events.OnRefreshInventoryWindowContainers.Add(function(self, state)
  if self.onCharacter then
    -- Ignore character containers, as usual
    return
  end

  if state == "begin" then    
    self:addProxInvButton()
  end

  if state == "buttonsAdded" then
    self:injectProxInvButton()
  end
end)
