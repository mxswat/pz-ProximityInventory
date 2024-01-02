-- local ProximityInventory = require "ProximityInventory/ProximityInventory"

-- -- Minor improvement to UX by not selecting the ProximityInventory container when toggling off
-- -- The game for some reason tries to select the container when it's locked

-- local old_ISInventoryPage_selectContainer = ISInventoryPage.selectContainer
-- function ISInventoryPage:selectContainer(button)	
--   if not ProximityInventory.isToggled and button.inventory == ProximityInventory.GetProxInvContainer(self.player)  then
--     return
--   end

-- 	return old_ISInventoryPage_selectContainer(self, button)
-- end
