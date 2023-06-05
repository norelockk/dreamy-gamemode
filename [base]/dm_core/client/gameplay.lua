local screenW, screenH = guiGetScreenSize()

-- rotating head
setTimer(function()
  local x, y, z = getWorldFromScreenPosition(screenW * 0.5, screenH * 0.5, 10)

  triggerLatentServerEvent('core:syncCharacterLookAt', 30000, false, localPlayer, x, y, z)
end, 200, 0)

addEvent('core:setCharacterLookAt', true)
addEventHandler('core:setCharacterLookAt', root, function(x, y, z)
  if isElement(source) and not getElementType(source) == 'player' then
    return
  end

  local isSpawned = getElementData(source, 'character:spawned')
  if not isSpawned then
    return
  end

  setPedLookAt(source, x, y, z)
end)
