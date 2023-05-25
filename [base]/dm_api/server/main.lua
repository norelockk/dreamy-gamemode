local saveGamePlayersAccounts_Timer
local refreshGamePlayersStatus_Timer

local function saveGamePlayersAccounts()
  for k, player in ipairs(getElementsByType('player')) do
    savePlayerAccount(player)
  end
end

local function logged(player)
  setPlayerAccountOnline(player, true)
end

local function quit()
  setPlayerAccountOnline(source, false)
  savePlayerAccount(source)
end

local function stop()
  saveGamePlayersAccounts()
  refreshGamePlayersStatus()

  if isTimer(refreshGamePlayersStatus_Timer) then
    killTimer(refreshGamePlayersStatus_Timer)
    refreshGamePlayersStatus_Timer = nil
  end

  if isTimer(saveGamePlayersAccounts_Timer) then
    killTimer(saveGamePlayersAccounts_Timer)
    saveGamePlayersAccounts_Timer = nil
  end
end

local function start()
  refreshGamePlayersStatus()

  if not saveGamePlayersAccounts_Timer and not isTimer(saveGamePlayersAccounts_Timer) then
    saveGamePlayersAccounts_Timer = setTimer(saveGamePlayersAccounts, 60 * 1000, 0)
  end

  if not refreshGamePlayersStatus_Timer and not isTimer(refreshGamePlayersStatus_Timer) then
    refreshGamePlayersStatus_Timer = setTimer(refreshGamePlayersStatus, 30 * 1000, 0)
  end

  addEventHandler('onPlayerQuit', root, quit)
  addEventHandler('api:onPlayerLogged', root, logged)
end
addEventHandler('onResourceStop', resourceRoot, stop)
addEventHandler('onResourceStart', resourceRoot, start)