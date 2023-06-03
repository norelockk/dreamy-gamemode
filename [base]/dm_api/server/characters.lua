-- settings
local MAX_CHARACTERS_PER_ACCOUNT = 3

-- resources
local CORE = exports.dm_core
local MYSQL = exports.mysql

-- event handlers
addEvent('api:onPlayerCharacterCreated', true)
addEvent('api:onPlayerCharacterSelected', true)

-- gathering all characters
function getAllGameCharacters(client)
  if not client or not getElementType(client) == 'player' then return 'GAME_CLIENT_UNIDENTIFIED' end
  
  -- check if player is logged
  local logged = getElementData(client, 'player:logged')
  if not logged then
    return 'CLIENT_NOT_LOGGED'
  end

  -- gathering current player data
  local owner = getElementData(client, 'player:aid')

  local characters = MYSQL:query(string.format('SELECT * FROM `character` WHERE `ownerId` = ? LIMIT %d', MAX_CHARACTERS_PER_ACCOUNT), owner)
  if #characters > 0 then
    return characters
  end

  return 'CLIENT_PLAYER_NO_CHARACTERS'
end

-- creating character
function createGameCharacter(client, data)
  if not client or not getElementType(client) == 'player' then return 'GAME_CLIENT_UNIDENTIFIED' end
  
  -- check if player is logged
  local logged = getElementData(client, 'player:logged')
  if not logged then
    return 'CLIENT_NOT_LOGGED'
  end

  -- gathering current player data
  local owner = getElementData(client, 'player:aid')

  -- checking character limit per account
  local characters = #MYSQL:query(string.format('SELECT * FROM `character` WHERE `ownerId` = ? LIMIT %d', MAX_CHARACTERS_PER_ACCOUNT), owner)
  if characters >= MAX_CHARACTERS_PER_ACCOUNT then
    return 'CLIENT_CHARACTERS_LIMIT_REACHED'
  end


end