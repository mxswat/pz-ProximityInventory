local ProximityInventory = require("ProximityInventory/ProximityInventory")

-- These fixes are needed to avoid crafting duplication bugs as the game tried to pull items from the ProximityInventory container

local old_ISCraftingUI_getContainers = ISCraftingUI.getContainers
function ISCraftingUI:getContainers()
	local result = old_ISCraftingUI_getContainers(self)
	if not self.character or not ProximityInventory.isToggled then
		return result
	end

  local proxInvContainer = ProximityInventory.GetProxInvContainer(self.playerNum)
	self.containerList:remove(proxInvContainer);
	return result
end

local old_ISInventoryPaneContextMenu_getContainers = ISInventoryPaneContextMenu.getContainers
ISInventoryPaneContextMenu.getContainers = function(character)
	if not character or not ProximityInventory.isToggled then
		return old_ISInventoryPaneContextMenu_getContainers(character)
	end
	
	local containerList = old_ISInventoryPaneContextMenu_getContainers(character)
  local proxInvContainer = ProximityInventory.GetProxInvContainer(character:getPlayerNum())

	containerList:remove(proxInvContainer);

	return containerList;
end