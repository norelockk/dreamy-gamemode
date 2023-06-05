-- settings
local MAX_CHARACTERS_PER_ACCOUNT = 3
local CHARACTERS_DETAILS = {
  AGE = { -- how much character could be old
    MIN = 16,
    MAX = 50
  },
  GROWTH = { -- how much character could be growth
    MIN = 160,
    MAX = 210
  },
  WEIGHT = { -- how much character can have weight
    MIN = 60,
    MAX = 120
  },
  LAST_NAME = { -- min & max character last name
    MIN = 4,
    MAX = 24
  },
  FIRST_NAME = { -- min & max character first name
    MIN = 3,
    MAX = 24
  }
}

-- resources
local CORE = exports.dm_core
local MYSQL = exports.mysql

-- event handlers
addEvent('api:onPlayerCharacterCreated', true)
addEvent('api:onPlayerCharacterSelected', true)

-- gathering all characters from player
function getAllGameCharacters(client)
  if not client or not getElementType(client) == 'player' then return 'GAME_CLIENT_UNIDENTIFIED' end

  -- check if player is logged
  local logged = getElementData(client, 'player:logged')
  if not logged then return 'CLIENT_NOT_LOGGED' end

  -- gathering current player data
  local owner = getElementData(client, 'player:aid')
  if not owner or not type(owner) == 'number' then return 'CLIENT_INVALID_OWNER_ID' end

  local characters = MYSQL:query(string.format('SELECT * FROM `character` WHERE `ownerId` = ? LIMIT %d', MAX_CHARACTERS_PER_ACCOUNT), owner)
  if #characters > 0 then
    return characters
  end

  return 'CLIENT_PLAYER_NO_CHARACTERS'
end

-- spawn character
function spawnGameCharacter(client, selectedCharacter)
  if not client or not getElementType(client) == 'player' then return 'GAME_CLIENT_UNIDENTIFIED' end

  -- check if player is logged
  local logged = getElementData(client, 'player:logged')
  if not logged then return 'CLIENT_NOT_LOGGED' end

  -- gathering current player data
  local owner = getElementData(client, 'player:aid')
  if not owner or not type(owner) == 'number' then return 'CLIENT_INVALID_OWNER_ID' end

  local spawned = getElementData(client, 'character:spawned')
  if spawned then return 'CLIENT_CHARACTER_ALREADY_SPAWNED' end

  local character = MYSQL:query('SELECT * FROM `character` WHERE `id` = ? LIMIT 1', selectedCharacter)[1]
  if not character then return 'CLIENT_UNKNOWN_CHARACTER' end

  -- check if character owner is proper
  if not character.ownerId == owner then return 'CLIENT_INVALID_CHARACTER_OWNER' end

  -- set element datas
  local _data = {
    ['character:id'] = character.id,
    ['character:age'] = character.age,
    ['character:skin'] = character.skin,
    ['character:class'] = character.class,
    ['character:owner'] = character.ownerId,
    ['character:growth'] = character.growth,
    ['character:weight'] = character.weight,
    ['character:gender'] = character.gender,
    ['character:spawned'] = true,
    ['character:last_name'] = character.lastName,
    ['character:first_name'] = character.firstName
  }
  for key, value in pairs(_data) do setElementData(client, key, value) end

  -- spawn player character
  local pos = Vector3(821.816, -1362.617, -0.505)
  local style = character.gender == 'FEMALE' and 129 or character.gender == 'MALE' and 118 or 0 

  spawnPlayer(client, pos, 0, character.skin, 0, 0)
  setCameraTarget(client, client)
  setElementHealth(client, character.health)
  setPedWalkingStyle(client, style)

  triggerEvent('api:onPlayerCharacterSelected', client, character)

  return 'CLIENT_CHARACTER_SPAWNED'
end

-- creating character
function createGameCharacter(client, data)
  if not client or not getElementType(client) == 'player' then return 'GAME_CLIENT_UNIDENTIFIED' end

  -- check if player is logged
  local logged = getElementData(client, 'player:logged')
  if not logged then return 'CLIENT_NOT_LOGGED' end

  -- gathering current player data
  local owner = getElementData(client, 'player:aid')
  if not owner or not type(owner) == 'number' then return 'CLIENT_INVALID_OWNER_ID' end

  -- checking character limit per account
  local characters = #MYSQL:query(string.format('SELECT `id` FROM `character` WHERE `ownerId` = ? LIMIT %d', MAX_CHARACTERS_PER_ACCOUNT), owner)
  if characters >= MAX_CHARACTERS_PER_ACCOUNT then return 'CLIENT_CHARACTERS_LIMIT_REACHED' end

  -- checking if first or last name is proper with length and is not already taken
  if not string.checkLen(data.firstName, CHARACTERS_DETAILS.FIRST_NAME.MIN, CHARACTERS_DETAILS.FIRST_NAME.MAX) then return 'CLIENT_FIRSTNAME_SHORT_OR_LONG' end
  if not string.checkLen(data.lastName, CHARACTERS_DETAILS.LAST_NAME.MIN, CHARACTERS_DETAILS.LAST_NAME.MAX) then return 'CLIENT_LASTNAME_SHORT_OR_LONG' end

  -- checking if first and last name is already taken
  local taken = false
  local characters = MYSQL:query('SELECT `firstName`, `lastName` FROM `character`')

  for i, character in ipairs(characters) do
    if character.firstName == data.firstName and character.lastName == data.lastName then
      taken = true
      break
    end
  end

  if taken then
    return 'CLIENT_CHARACTER_ALREADY_TAKEN'
  end

  -- checking if 
end
