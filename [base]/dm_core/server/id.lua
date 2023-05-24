local ID = {}

local function findFreeID(co, plr, freeID, count)
  while true do
    if isElement(ID[freeID]) then
      freeID = freeID + 1
      count = count + 1

      if count >= 25 then
        setTimer(function()
          coroutine.resume(co, co, plr, freeID, 0) 
        end, 50, 1)

        coroutine.yield(co)
      end
    else
      ID[freeID] = plr
      setElementID(plr, string.format('player_%d', freeID))
      setElementData(plr, 'player:id', freeID) 
      break
    end
  end
end

local function setPlayerID(plr)
  if not plr or not isElement(plr) then return end

  local co = coroutine.create(findFreeID)
  coroutine.resume(co, co, plr, 1, 0)
end

local function start()
  local function join()
    return setPlayerID(source)
  end

  local function quit()
    local plrID = getElementData(source, 'player:id')
    if not plrID then return end

    ID[plrID] = nil
  end

  for _, player in pairs(getElementsByType('player')) do
    setPlayerID(player)
  end

  addEventHandler('onPlayerJoin', root, join)
  addEventHandler('onPlayerQuit', root, quit)
end
addEventHandler('onResourceStart', resourceRoot, start)