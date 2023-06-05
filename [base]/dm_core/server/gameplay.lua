local function start()
  setMinuteDuration(60000)
end
addEventHandler('onResourceStart', resourceRoot, start)

local function syncTime()
  local realtime = getRealTime()

  setTime(realtime.hour, realtime.minute)
end
setTimer(syncTime, 30000, 0)

addEvent('core:syncCharacterLookAt', true)
addEventHandler('core:syncCharacterLookAt', root, function(x, y, z)
  triggerLatentClientEvent('core:setCharacterLookAt', 30000, false, client, x, y, z)
end)