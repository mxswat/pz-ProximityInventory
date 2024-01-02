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
    print("ToggleForceSelected called!")
  end
end

Events.OnKeyPressed.Add(ProxInvKeybindings.OnKeyPressed);
