local runFunctionPerTick = require "ProximityInventory/runFunctionPerTick"

local zombieTypes = {
  inventoryfemale = true,
  inventorymale = true,
}

---@class ProxInv
local ProximityInventory = {}

function ProximityInventory.print(...)
  if not isDebugEnabled() then return end
  print("[ProxInv]", ...)
end

ProximityInventory.isToggled = false
ProximityInventory.inventoryIcon = getTexture("media/ui/ProximityInventory.png")

function ProximityInventory.GetPlayerProxInv(playerNum)
  if ProximityInventory.proxInvContainer == nil then
    ProximityInventory.proxInvContainer = {}
  end
  if ProximityInventory.proxInvContainer[playerNum + 1] == nil then
    ProximityInventory.proxInvContainer[playerNum + 1] = ItemContainer.new("proxInv", nil, nil, 10, 10)
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
  local proxInvContainer = ProximityInventory.GetPlayerProxInv(invPage.player)

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

---@param invPage ISInventoryPage
function ProximityInventory.OnBegin(invPage)
  local playerObj = getSpecificPlayer(invPage.player)

  local localContainer = ProximityInventory.GetPlayerProxInv(invPage.player)
  -- Always clear before doing anything with it
  localContainer:clear()

  local title = getText("UI_ProxInv")
  local proxInvButton = invPage:addContainerButton(localContainer, ProximityInventory.inventoryIcon, title, 'Tooltip')
  proxInvButton.capacity = 0
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

Events.OnRefreshInventoryWindowContainers.Add(ProximityInventory.OnRefreshInventoryWindowContainers)
