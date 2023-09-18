local function isZombieOnly()
  return SandboxVars.ProxInv.ZombieOnly
end

function ISInventoryPage.GetProxInvContainer(playerNum)
  if ISInventoryPage.proxInvContainer == nil then
    ISInventoryPage.proxInvContainer = {}
  end
  if ISInventoryPage.proxInvContainer[playerNum + 1] == nil then
    ISInventoryPage.proxInvContainer[playerNum + 1] = ItemContainer.new(ProxInv.containerType, nil, nil, 10, 10)
    ISInventoryPage.proxInvContainer[playerNum + 1]:setExplored(true)
    ISInventoryPage.proxInvContainer[playerNum + 1]:setOnlyAcceptCategory("AbsolutelyNoItemAllowed")
    ISInventoryPage.proxInvContainer[playerNum + 1]:setCapacity(0)
  end
  return ISInventoryPage.proxInvContainer[playerNum + 1]
end

function ISInventoryPage:getProxInvIcon()
  if not ProxInv.Options.enableProxInv then
    return ProxInv.icons.disabled
  end
  return isZombieOnly() and ProxInv.icons.corpse or ProxInv.icons.enabled
end

function ISInventoryPage:addProxInvButton()
  if self.proxInvButton then
    -- This avoid the generation of multiple buttons when enableProxInv is false
    self:removeChild(self.proxInvButton)
  end

  local proxInvContainer = ISInventoryPage.GetProxInvContainer(self.player)
  -- proxInvContainer:removeItemsFromProcessItems() -- NO, NEVER ENABLE THIS OR SHIT WONT COOK/FREEZE
  proxInvContainer:clear()

  local title = isZombieOnly() and getText("IGUI_ProxInv_Corpses") or getText("IGUI_ProxInv")
  self.proxInvButton = self:addContainerButton(proxInvContainer, self:getProxInvIcon(), title, getText("Sandbox_ProxInv"))

  if not ProxInv.Options.enableProxInv then
    self.proxInvButton.onclick = nil
    self.proxInvButton.onmousedown = nil
  end

  if ProxInv.isForceSelected then
    self.wasProxInvSelected = true
    self.forceSelectedContainer = nil
    self.proxInvButton.textureOverride = getTexture("media/ui/Panel_Icon_Pin.png");
  end

  if self.forceSelectedContainer and self.forceSelectedContainer:getType() ~= ProxInv.containerType then
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
  if not ProxInv.Options.enableProxInv then
    return false
  end
  if isZombieOnly() then
    return ProxInv.zombieContainerTypes[container:getType()]
  end

  return not self:isContainerLocked(container, self.player)
end

function ISInventoryPage:injectProxInvItems()
  for i = 1, #self.backpacks do
    local button = self.backpacks[i]
    local container = self.backpacks[i].inventory
    if button ~= self.proxInvButton then
      if self:canBeAddedToProxInv(container) then
        local items = container:getItems()
        self.proxInvButton.inventory:getItems():addAll(items)
      end
    end
  end
end

Events.OnRefreshInventoryWindowContainers.Add(function(self, state)
  if self.onCharacter then
    -- Ignore character containers, as usual
    -- Or if disabled
    return
  end

  if state == "begin" then
    self.wasProxInvSelected = self.inventoryPane.lastinventory == (self.proxInvButton and self.proxInvButton.inventory)
    if ProxInv.Options.alwaysAsFirst then
      self:addProxInvButton()
    end
  end
  if state == "buttonsAdded" then
    self:injectProxInvItems()
    if not ProxInv.Options.alwaysAsFirst then
      self:addProxInvButton()
    end
  end
end)


-- Handles the disabled state, so that on scroll, it won't select the prox inv when disabled

local old_ISInventoryPage_prevUnlockedContainer = ISInventoryPage.prevUnlockedContainer
function ISInventoryPage:prevUnlockedContainer(index, wrap)
  local result = old_ISInventoryPage_prevUnlockedContainer(self, index, wrap)

  if not ProxInv.Options.enableProxInv and self.backpacks[result] and self.backpacks[result].ID == self.proxInvButton.ID then
    return old_ISInventoryPage_prevUnlockedContainer(self, index - 1, wrap)
  end

  return result
end

local old_ISInventoryPage_nextUnlockedContainer = ISInventoryPage.nextUnlockedContainer
function ISInventoryPage:nextUnlockedContainer(index, wrap)
  local result = old_ISInventoryPage_nextUnlockedContainer(self, index, wrap)

  if not ProxInv.Options.enableProxInv and self.backpacks[result] and self.backpacks[result].ID == self.proxInvButton.ID then
    return old_ISInventoryPage_nextUnlockedContainer(self, index + 1, wrap)
  end

  return result
end
