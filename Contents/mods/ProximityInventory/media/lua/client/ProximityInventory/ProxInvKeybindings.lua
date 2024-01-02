local ProximityInventory = require "ProximityInventory/ProximityInventory"
local ProxInvKeybindings = {};

ProxInvKeybindings.ToggleForceSelectedKeybind = {
  value = 'ToggleForceSelected',
  key = Keyboard.KEY_NUMPAD0
}

table.insert(keyBinding, {
  value = "[ProximityInventory]"
});
table.insert(keyBinding, ProxInvKeybindings.ToggleForceSelectedKeybind);

function ProxInvKeybindings.OnKeyPressed(key)
  if key == getCore():getKey(ProxInvKeybindings.ToggleForceSelectedKeybind.value) then
    local player = getSpecificPlayer(0)
    ProximityInventory.isForceSelected = not ProximityInventory.isForceSelected
    ProximityInventory.refreshUI()
    local text = getText("IGUI_ProxInv_Force_Selected") .. (ProximityInventory.isForceSelected and "ON" or "OFF")
		HaloTextHelper.addText(player, text, HaloTextHelper.getColorWhite())
  end
end

Events.OnKeyPressed.Add(ProxInvKeybindings.OnKeyPressed);
