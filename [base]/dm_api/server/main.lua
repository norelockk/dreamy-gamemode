local refreshGamePlayersStatus_Timer

local function logged(player)
  setPlayerAccountOnline(player, true)
end

local function quit()
  setPlayerAccountOnline(source, false)
end

local function start()
  refreshGamePlayersStatus()

  if not refreshGamePlayersStatus_Timer and not isTimer(refreshGamePlayersStatus_Timer) then
    refreshGamePlayersStatus_Timer = setTimer(refreshGamePlayersStatus, 30 * 1000, 0)
  end

  addEventHandler('onPlayerQuit', root, quit)
  addEventHandler('api:onPlayerLogged', root, logged)
end
addEventHandler('onResourceStart', resourceRoot, start)