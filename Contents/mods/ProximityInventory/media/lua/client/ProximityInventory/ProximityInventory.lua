local proxInvIcon = getTexture("media/ui/ProximityInventory.png")

function ISInventoryPage.GetProxInvContainer(playerNum)
  if ISInventoryPage.proxInvContainer == nil then
    ISInventoryPage.proxInvContainer = {}
  end
  if ISInventoryPage.proxInvContainer[playerNum + 1] == nil then
    ISInventoryPage.proxInvContainer[playerNum + 1] = ItemContainer.new("proxinv", nil, nil, 10, 10)
    ISInventoryPage.proxInvContainer[playerNum + 1]:setExplored(true)
    ISInventoryPage.proxInvContainer[playerNum + 1]:setOnlyAcceptCategory("AbsolutelyNoItemAllowed")
    ISInventoryPage.proxInvContainer[playerNum + 1]:setCapacity(0)
  end
  return ISInventoryPage.proxInvContainer[playerNum + 1]
end

function ISInventoryPage:addProxInvButton()
  local proxInvContainer = ISInventoryPage.GetProxInvContainer(self.player)
  proxInvContainer:removeItemsFromProcessItems()
  proxInvContainer:clear()

  local title = getText("IGUI_ProxInv")
  self.proxInvButton = self:addContainerButton(proxInvContainer, proxInvIcon, title, title)
  self.proxInvButton:setY(self:titleBarHeight() - 1)

  if self.forceSelectedContainer and self.forceSelectedContainer:getType() ~= "proxinv" then
    -- game is forcing a different container
    return
  end
  if not self.wasProxInvSelected then
    return
  end
  -- This makes it so that when proxInv is selected, it stays selected util: 
  -- - the game forces a different container
  -- - the user selects something else
  -- IMHO this is probably my best version of this mod to date
  self.forceSelectedContainer = self.proxInvButton.inventory
  self.forceSelectedContainerTime = getTimestampMs() + 200
end

function ISInventoryPage:isContainerLocked(container, player)
  local playerObj = getSpecificPlayer(player)
  local object = container:getParent()
  return object and instanceof(object, "IsoThumpable") and object:isLockedToCharacter(playerObj)
end

function ISInventoryPage:canBeAddedToProxInv(container)
  if SandboxVars.ProxInv.ZombieOnly then
    return ProxInv.zombieContainerTypes[container:getType()]
  end

  return not self:isContainerLocked(container, self.player)
end

function ISInventoryPage:injectProxInvButton()
  for i = 1, #self.backpacks do
    local button = self.backpacks[i]
    local container = self.backpacks[i].inventory
    if button ~= self.proxInvButton then
      if self:canBeAddedToProxInv(container) then
        local items = container:getItems()
        self.proxInvButton.inventory:getItems():addAll(items)
      end
      button:setY(button:getY() + button:getHeight())
    end
  end
end

Events.OnRefreshInventoryWindowContainers.Add(function(self, state)
  if self.onCharacter then
    -- Ignore character containers, as usual
    return
  end

  if state == "begin" then
    self.wasProxInvSelected = self.inventoryPane.lastinventory == (self.proxInvButton and self.proxInvButton.inventory)
  end
  if state == "buttonsAdded" then
    self:addProxInvButton()
    self:injectProxInvButton()
  end
end)
