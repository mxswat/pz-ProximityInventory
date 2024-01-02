---@diagnostic disable: inject-field
local runFunctionPerTick = require "ProximityInventory/runFunctionPerTick"

local zombieTypes = {
  inventoryfemale = true,
  inventorymale = true,
}

---@class (exact) ProxInv
local ProximityInventory = {}

ProximityInventory.isToggled = true
ProximityInventory.isHighlightEnable = true
ProximityInventory.isForceSelected = false
ProximityInventory.inventoryIcon = getTexture("media/ui/ProximityInventory.png")
ProximityInventory.proxInvContainer = {}

function ProximityInventory.print(...)
  if not isDebugEnabled() then return end
  print("[ProxInv]", ...)
end

--- @return ItemContainer
function ProximityInventory.GetProxInvContainer(playerNum)
  if ProximityInventory.proxInvContainer[playerNum + 1] == nil then
    ProximityInventory.proxInvContainer[playerNum + 1] = ItemContainer.new("proxInv", nil, nil, 10)
    ProximityInventory.proxInvContainer[playerNum + 1]:setExplored(true)
    ProximityInventory.proxInvContainer[playerNum + 1]:setOnlyAcceptCategory("none")
    ProximityInventory.proxInvContainer[playerNum + 1]:setCapacity(0)
  end
  return ProximityInventory.proxInvContainer[playerNum + 1]
end

function ProximityInventory.canBeAdded(container, playerObj)
  local object = container:getParent()

  -- Don't allow if not a zombie if ZombieOnly is ON
  if SandboxVars.ProxInv.ZombieOnly then
    return zombieTypes[container:getType()]
  end

  -- Don't allow to see inside containers locked to you
  if object and instanceof(object, "IsoThumpable") and object:isLockedToCharacter(playerObj) then
    return false
  end

  return true
end

---@type table<number, number>
ProximityInventory.lastRefreshTime = {}
ProximityInventory.debounceDelay = 250
function ProximityInventory.OnButtonsAddedDebounced(invPage)
  if not ProximityInventory.isToggled then return end

  -- Initialize the lastRefreshTime for the player
  ProximityInventory.lastRefreshTime[invPage.player] = ProximityInventory.lastRefreshTime[invPage.player] or 0

  local currentTime = math.floor(os.time() * 1000)
  local lastRefreshTime = ProximityInventory.lastRefreshTime[invPage.player]

  -- Debounce to help with performance
  if currentTime - lastRefreshTime < ProximityInventory.debounceDelay then
    return ProximityInventory.print("Debounced")
  end
  ProximityInventory.lastRefreshTime[invPage.player] = currentTime

  ProximityInventory.OnButtonsAdded(invPage)
end

---@param invPage ISInventoryPage
function ProximityInventory.OnButtonsAdded(invPage)
  ProximityInventory.print("OnButtonsAdded")

  local playerObj = getSpecificPlayer(invPage.player)
  local proxInvContainer = ProximityInventory.GetProxInvContainer(invPage.player)

  local argumentsTable = {}
  for i, value in ipairs(invPage.backpacks) do
    ---@class ProximityInventory.AddContainerItemsToProxInvArguments
    ---@field container ItemContainer
    ---@field proxInvContainer ItemContainer
    ---@field invPage ISInventoryPage
    local arguments = {
      container = value.inventory,
      playerObj = playerObj,
      proxInvContainer = proxInvContainer,
      invPage = invPage,
      isLast = i == #invPage.backpacks
    }

    table.insert(argumentsTable, arguments)
  end

  runFunctionPerTick(ProximityInventory.AddContainerItemsToProxInv, argumentsTable)

  if ProximityInventory.isToggled and ProximityInventory.isForceSelected then
    invPage:setForceSelectedContainer(proxInvContainer)
  end
end

---@param arguments ProximityInventory.AddContainerItemsToProxInvArguments
function ProximityInventory.AddContainerItemsToProxInv(arguments)
  local playerObj = arguments.playerObj
  local proxInvContainer = arguments.proxInvContainer
  local container = arguments.container
  local invPage = arguments.invPage
  local isLast = arguments.isLast

  if container == proxInvContainer then return end
  if not ProximityInventory.canBeAdded(container, playerObj) then return end

  ProximityInventory.print("Adding items from " .. container:getType())

  ---@diagnostic disable-next-line: param-type-mismatch
  proxInvContainer:getItems():addAll(container:getItems())

  if invPage.inventoryPane and isLast then
    ProximityInventory.print("Refreshing InventoryPane")
    invPage.inventoryPane:refreshContainer()
  end
end

local pinnedIcon = getTexture("media/ui/Panel_Icon_Pin.png")

---@param invPage ISInventoryPage
function ProximityInventory.OnBegin(invPage)
  local playerObj = getSpecificPlayer(invPage.player)

  local proxInvContainer = ProximityInventory.GetProxInvContainer(invPage.player)
  -- Always clear before doing anything with it
  proxInvContainer:clear()
  proxInvContainer:setParent(nil)

  local title = getText("UI_ProxInv")
  local tooltip = getText("IGUI_ProxInv_Toggled") .. (ProximityInventory.isToggled and "ON" or "OFF")
  tooltip = tooltip ..
  "\n" .. getText("IGUI_ProxInv_Force_Selected") .. (ProximityInventory.isForceSelected and "ON" or "OFF")
  tooltip = tooltip ..
  "\n" .. getText("IGUI_ProxInv_Highlight") .. (ProximityInventory.isHighlightEnable and "ON" or "OFF")
  local proxInvButton = invPage:addContainerButton(proxInvContainer, ProximityInventory.inventoryIcon, title, tooltip)
  proxInvButton.textureOverride = ProximityInventory.isForceSelected and pinnedIcon or nil

  if not ProximityInventory.isToggled then
    proxInvButton.onclick = function() end
    proxInvButton.onmousedown = function() end
    proxInvButton:setOnMouseOverFunction(nil)
    proxInvButton:setOnMouseOutFunction(nil)
    proxInvButton.textureOverride = getTexture("media/ui/lock.png")

    local parent = IsoThumpable.new(getCell(), getCell():getGridSquare(0, 0, 0), "camping_01_10", false, {});
    parent:setLockedByCode(1)
    proxInvContainer:setParent(parent)
  end
end

---@param invPage ISInventoryPage
---@param state string
function ProximityInventory.OnRefreshInventoryWindowContainers(invPage, state)
  -- Ignore character containers, as usual
  if invPage.onCharacter then return end

  if state == "begin" then
    return ProximityInventory.OnBegin(invPage)
  elseif state == "buttonsAdded" then
    return ProximityInventory.OnButtonsAddedDebounced(invPage)
  end
end

function ProximityInventory.refreshUI()
  ISInventoryPage.dirtyUI()
end

Events.OnRefreshInventoryWindowContainers.Add(ProximityInventory.OnRefreshInventoryWindowContainers)

return ProximityInventory
