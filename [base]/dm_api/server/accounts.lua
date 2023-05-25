-- settings
local VERIFY_EMAIL = true
local ACCOUNT_DETAILS = {
  USERNAME = {
    MIN = 3,
    MAX = 24
  },
  PASSWORD = {
    MIN = 6,
    MAX = 32
  }
}
local VERIFY_ACCOUNT_SERIAL = true
local MAX_ACCOUNTS_PER_SERIAL = 2

-- event handlers
addEvent('api:onPlayerLogged', true)

-- resources
local CORE = exports.dm_core
local MYSQL = exports.mysql

-- creating account
function createGameAccount(client, data)
  if not client or not getElementType(client) == 'player' then return 'GAME_CLIENT_UNIDENTIFIED' end

  -- gathering current player data
  local serial = getPlayerSerial(client)

  -- checking account limit per serial
  if VERIFY_ACCOUNT_SERIAL then
    local accounts = #MYSQL:query(string.format('SELECT * FROM `account` WHERE `serial` = ? LIMIT %d', MAX_ACCOUNTS_PER_SERIAL), serial)
    if accounts >= MAX_ACCOUNTS_PER_SERIAL then
      return 'CLIENT_ACCOUNTS_LIMIT_REACHED'
    end
  end

  -- checking if username or email is already taken & making sure is everything perfect
  if not string.checkLen(data.username, ACCOUNT_DETAILS.USERNAME.MIN, ACCOUNT_DETAILS.USERNAME.MAX) then return 'CLIENT_USERNAME_SHORT_OR_LONG' end
  if not string.checkLen(data.password, ACCOUNT_DETAILS.PASSWORD.MIN, ACCOUNT_DETAILS.PASSWORD.MAX) then return 'CLIENT_PASSWORD_SHORT_OR_LONG' end

  if VERIFY_EMAIL then
    if not data.email or not type(data.email) == 'string' then
      return 'CLIENT_NO_EMAIL'
    end

    if not validateEmail(data.email) then
      return 'CLIENT_INVALID_EMAIL'
    end

    local emailTaken = #MYSQL:query('SELECT `id` FROM `account` WHERE `email` = ? LIMIT 1', data.email) >= 1
    if emailTaken then
      return 'CLIENT_EMAIL_ALREADY_TAKEN'
    end
  end

  local usernameTaken = #MYSQL:query('SELECT `id` FROM `account` WHERE `username` = ? LIMIT 1', data.username) >= 1
  if usernameTaken then return 'CLIENT_USERNAME_ALREADY_TAKEN' end

  -- hashing password and making new account
  local hashedPassword = passwordHash(data.password, 'bcrypt', {["salt"] = nil, ["cost"] = 10})

  local created = MYSQL:queryFree('INSERT INTO `account` (`email`, `serial`, `username`, `password`, `lastOnline`, `createdAt`, `updatedAt`) VALUES(?, ?, ?, ?, CURRENT_TIME(), CURRENT_TIME(), CURRENT_TIME())', data.email, serial, data.username, hashedPassword)
  if created then
    return 'CLIENT_ACCOUNT_CREATED'
  end

  return 'CLIENT_UNKNOWN_ERROR'
end

-- checking is someone is already logged in that account
local function checkIsSomeoneLogged(account)
  if not account then return false end

  for _, player in ipairs(getElementsByType('player')) do
    local accId = getElementData(player, 'player:account_id')

    if account.id == accId then
      return true
    end
  end

  return false
end

-- logging into account
function loginGameAccount(client, data)
  if not client or not getElementType(client) == 'player' then return 'GAME_CLIENT_UNIDENTIFIED' end

  -- gathering current player data
  local accountId = getElementData(client, 'player:account_id')
  local logged = getElementData(client, 'player:logged')
  local serial = getPlayerSerial(client)
  local name = getPlayerName(client)

  -- check if player is already 'for sure' logged
  if logged and accountId then return 'CLIENT_ALREADY_LOGGED' end

  -- check if account exists by providen username
  local account = MYSQL:query('SELECT * FROM `account` WHERE `username` = ? LIMIT 1', data.username)[1]
  if account then
    -- if account exists let's verify some things (serial, is someone else is not logged & password)
    if VERIFY_ACCOUNT_SERIAL then
      if not account.serial == serial then
        return 'CLIENT_INVALID_SERIAL'
      end
    end

    local isSomeoneLogged = checkIsSomeoneLogged(account)

    if isSomeoneLogged then
      return 'CLIENT_ACCOUNT_SOMEONE_LOGGED'
    end

    -- elements data to set
    local _data = {
      ['player:bw'] = account.bw,
      ['player:role'] = account.role,
      ['player:jail'] = account.jail,
      ['player:wanted'] = account.wanted ~= 0,
      ['player:logged'] = true,
      ['player:spawned'] = false,
      ['player:warnings'] = account.warnings,
      ['player:playtime'] = account.playtime,
      ['player:reputation'] = account.reputation,
      ['player:account_id'] = account.id
    }

    local passwordHashVaild = passwordVerify(data.password, account.password)

    if passwordHashVaild then
      if account.bw ~= 0 then
        
      end

      if account.wanted ~= 0 then setPlayerWantedLevel(client, account.wanted) end
      if name ~= account.username then setPlayerName(client, account.username) end
      
      for key, value in pairs(_data) do
        setElementData(client, key, value)
      end
      
      triggerEvent('api:onPlayerLogged', resourceRoot, client)

      return 'CLIENT_LOGIN_SUCCESS'
    else return 'CLIENT_ACCOUNT_INVALID_PASSWORD' end
  else return 'CLIENT_ACCOUNT_NOT_EXISTS' end

  return 'CLIENT_UNKNOWN_ERROR'
end

-- getting player by account id
function findPlayerByAccountId(accountId)
  if not accountId or not type(accountId) == 'number' then return end

  for k, player in ipairs(getElementsByType('player')) do
    local accId = getElementData(player, 'player:account_id')

    if accountId == accId then
      return player
    end
  end

  return nil
end

-- setting player status online (in db ofc)
function setPlayerAccountOnline(player, state)
  if not player or not getElementType(player) == 'player' then return end

  local logged = getElementData(player, 'player:logged')
  if not logged then return end

  local accountId = getElementData(player, 'player:account_id')
  if not accountId or not type(accountId) == 'number' then return end

  local updated = MYSQL:queryFree(state and 'UPDATE `account` SET `online` = 1 WHERE `id` = ?' or 'UPDATE `account` SET `online` = 0, `lastOnline` = CURRENT_TIME() WHERE `id` = ?', accountId)
  if updated then return true end

  return false
end

-- refreshing player status
function refreshGamePlayersStatus()
  -- get available accounts in database
  local players = MYSQL:query('SELECT `online`, `id` FROM `account`')

  for k, v in ipairs(players) do
    -- check if player is in-game so we can verify his online status
    local player = findPlayerByAccountId(v.id)

    if not player and not isElement(player) then
      if v.online ~= 0 then
        MYSQL:queryFree('UPDATE `account` SET `online` = 0, `lastOnline` = CURRENT_TIME() WHERE `id` = ?', v.id)
      end
    end
  end
end

-- saving player account data
function savePlayerAccount(player)
  if not player or not getElementType(player) == 'player' then return false end

  local logged = getElementData(player, 'player:logged')
  if not logged then return false end

  local accountId = getElementData(player, 'player:account_id')
  if not accountId or not type(accountId) == 'number' then return false end

  -- data
  local bw = getElementData(player, 'player:bw')
  local jail = getElementData(player, 'player:jail')
  local money = CORE:getGamePlayerMoney(player)
  local health = getElementHealth(player)
  local wanted = getPlayerWantedLevel(player)
  local warnings = getElementData(player, 'player:warnings')
  local playtime = getElementData(player, 'player:playtime')
  local reputation = getElementData(player, 'player:reputation')

  local updated = MYSQL:queryFree(
    'UPDATE `account` SET `bw` = ?, `jail` = ?, `money` = ?, `warnings` = ?, `playtime` = ?, `health` = ?, `wanted` = ?, `reputation` = ?, `updatedAt` = CURRENT_TIME() WHERE `id` = ?',
    bw, jail, money, warnings, playtime, health, wanted, reputation,
    accountId
  )

  if updated then
    print('account updated', accountId)

    return true
  end

  return false
end