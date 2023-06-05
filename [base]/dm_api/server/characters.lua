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

-- gathering all characters
function getAllGameCharacters(client)
  if not client or not getElementType(client) == 'player' then
    return 'GAME_CLIENT_UNIDENTIFIED'
  end

  -- check if player is logged
  local logged = getElementData(client, 'player:logged')
  if not logged then
    return 'CLIENT_NOT_LOGGED'
  end

  -- gathering current player data
  local owner = getElementData(client, 'player:aid')
  if not owner or not type(owner) == 'number' then
    return 'CLIENT_INVALID_OWNER_ID'
  end

  local characters = MYSQL:query(string.format('SELECT * FROM `character` WHERE `ownerId` = ? LIMIT %d', MAX_CHARACTERS_PER_ACCOUNT), owner)
  if #characters > 0 then
    return characters
  end

  return 'CLIENT_PLAYER_NO_CHARACTERS'
end

-- creating character
function createGameCharacter(client, data)
  if not client or not getElementType(client) == 'player' then
    return 'GAME_CLIENT_UNIDENTIFIED'
  end

  -- check if player is logged
  local logged = getElementData(client, 'player:logged')
  if not logged then
    return 'CLIENT_NOT_LOGGED'
  end

  -- gathering current player data
  local owner = getElementData(client, 'player:aid')
  if not owner or not type(owner) == 'number' then
    return 'CLIENT_INVALID_OWNER_ID'
  end

  -- checking character limit per account
  local characters = #MYSQL:query(string.format('SELECT `id` FROM `character` WHERE `ownerId` = ? LIMIT %d', MAX_CHARACTERS_PER_ACCOUNT), owner)
  if characters >= MAX_CHARACTERS_PER_ACCOUNT then
    return 'CLIENT_CHARACTERS_LIMIT_REACHED'
  end

  -- checking if first or last name is proper with length and is not already taken
  if not string.checkLen(data.firstName, CHARACTERS_DETAILS.FIRST_NAME.MIN, CHARACTERS_DETAILS.FIRST_NAME.MAX) then
    return 'CLIENT_FIRSTNAME_SHORT_OR_LONG'
  end
  if not string.checkLen(data.lastName, CHARACTERS_DETAILS.LAST_NAME.MIN, CHARACTERS_DETAILS.LAST_NAME.MAX) then
    return 'CLIENT_LASTNAME_SHORT_OR_LONG'
  end

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
