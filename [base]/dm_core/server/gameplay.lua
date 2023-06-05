addEvent('core:syncCharacterLookAt', true)
addEventHandler('core:syncCharacterLookAt', root, function(x, y, z)
  triggerLatentClientEvent('core:setCharacterLookAt', 30000, false, client, x, y, z)
end)