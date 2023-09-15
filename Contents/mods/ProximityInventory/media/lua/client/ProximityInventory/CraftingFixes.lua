local old_ISCraftingUI_getContainers = ISCraftingUI.getContainers
function ISCraftingUI:getContainers()
	local result = old_ISCraftingUI_getContainers(self)
	if not self.character or not ProxInv.isToggled then
		return result
	end

	local proxInvContainer = ISInventoryPage.GetProxInvContainer(self.playerNum)
	self.containerList:remove(proxInvContainer);
	return result
end

local old_ISInventoryPaneContextMenu_getContainers = ISInventoryPaneContextMenu.getContainers
ISInventoryPaneContextMenu.getContainers = function(character)
	if not character or not ProxInv.isToggled then
		return old_ISInventoryPaneContextMenu_getContainers(character)
	end
	
	local containerList = old_ISInventoryPaneContextMenu_getContainers(character)
	local proxInvContainer = ISInventoryPage.GetProxInvContainer(character:getPlayerNum())

	containerList:remove(proxInvContainer);

	return containerList;
end
