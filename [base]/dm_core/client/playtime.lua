local PAYDAY_DATA = {
  normal = {
    cash = 20,
    reputation = 1
  },
  premium = {
    cash = 80,
    reputation = 2
  }
}

local function payday()
  local data = PAYDAY_DATA[getElementData(localPlayer, 'player:premium') and 'premium' or 'normal']
  giveGamePlayerMoney(data.cash)

  local reputation = getElementData(localPlayer, 'player:reputation')
  reputation = reputation + data.reputation
  setElementData(localPlayer, 'player:reputation', reputation)
end

local session = 0
local playtime = -1

local function calculate()
  -- if not getElementData(localPlayer, 'player:spawned') then return end
  if getElementData(localPlayer, 'player:away') then
    return
  end

  if playtime == -1 then
    local p = getElementData(localPlayer, 'player:playtime')
    if not p then
      return
    else
      playtime = p
    end
  end

  playtime = playtime + 1
  session = session + 1

  if session > 3600 * 8 then -- 8 h
    -- No-life
  end

  if session > 0 and (session / 60) / 60 == math.floor((session / 60) / 60) and session % 60 == 0 then
    payday()
  end

  if getRealTime().hour >= 1 and getRealTime().hour <= 5 then
    -- Nocny gracz
  end
end
setTimer(calculate, 1000, 0)

local function update()
  -- if not getElementData(localPlayer, 'player:spawned') then return end
  if getElementData(localPlayer, 'player:away') then
    return
  end

  if playtime == -1 then
    return
  end

  triggerServerEvent('core:onPlayerUpdatePlaytime', resourceRoot, playtime, session)
end
setTimer(update, 60000 * 5, 0)
