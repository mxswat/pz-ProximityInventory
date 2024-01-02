local ProximityInventory = require("ProximityInventory/ProximityInventory")

local old_ISInventoryPage_update = ISInventoryPage.update
function ISInventoryPage:update()
	local result = old_ISInventoryPage_update(self)

	if self.onCharacter then
		return result
	end

	self.coloredProxInventories = self.coloredProxInventories or {}

	for _, container in ipairs(self.coloredProxInventories) do
		if container:getParent() then
			container:getParent():setHighlighted(false)
      container:getParent():setOutlineHighlight(false);
		end
	end
	table.wipe(self.coloredProxInventories)

	if ProximityInventory.isHighlightEnable and not self.isCollapsed and self.inventory == ProximityInventory.GetProxInvContainer(self.player) then
		for _, backpack in ipairs(self.backpacks) do
      local container = backpack.inventory
			if container:getParent() and (instanceof(container:getParent(), "IsoObject") or instanceof(container:getParent(), "IsoDeadBody")) then
				container:getParent():setHighlighted(true, false)
				container:getParent():setHighlightColor(getCore():getObjectHighlitedColor())
        if getCore():getOptionDoContainerOutline() then
          container:getParent():setOutlineHighlight(true);
          container:getParent():setOutlineHighlightCol(1, 1, 1, 1);
        end
				table.insert(self.coloredProxInventories, container)
			end
		end
	end

	return result
end