local loginTries = {}

local function securityFault(player)
  local ip = getPlayerIP(player)

  if not loginTries[ip] then
    loginTries[ip] = {
      timestamp = getRealTime().timestamp,
      tries = 0
    }
  end

  loginTries[ip].tries = loginTries[ip].tries + 1
  loginTries[ip].timestamp = getRealTime().timestamp
end

local API = exports.dm_api

-- handle events
addEvent('login:sendRequest', true)

-- functions
local function request(_type, data)
  if not client or not isElement(client) then return end
  if not getElementType(client) == 'player' then return end

  local response

  switch(_type)
  .case('login', function()
    local ip = getPlayerIP(client)

    if loginTries[ip] and loginTries[ip].tries >= 5 then
      if loginTries[ip].timestamp + 60 * 1 > getRealTime( ).timestamp then
        triggerClientEvent(client, 'login:onClientResponse', resourceRoot, {
          type = 'login',
          success = false,
          message = 'Odczekaj minutę przed następną próbą uwierzytelniania'
        })
        return
      end
    end

    response = API:loginGameAccount(client, data)

    switch(response)
    -- errors
    .case('CLIENT_UNKNOWN_ERROR', function()
      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, {
        type = 'login',
        success = false,
        message = 'Wystąpił błąd podczas uwierzytelniania (błąd API)'
      })
    end)
    .case('CLIENT_ALREADY_LOGGED', function()
      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, {
        type = 'login',
        success = false,
        message = 'Jesteś już zalogowany!'
      })
    end)
    .case('CLIENT_INVALID_SERIAL', function()
      securityFault(client)

      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, {
        type = 'login',
        success = false,
        message = 'Te konto nie należy do ciebie!'
      })
    end)
    .case('CLIENT_ACCOUNT_NOT_EXISTS', function()
      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, {
        type = 'login',
        success = false,
        message = 'Konto do którego próbujesz sie zalogować nie istnieje w bazie!'
      })
    end)
    .case('CLIENT_ACCOUNT_SOMEONE_LOGGED', function()
      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, {
        type = 'login',
        success = false,
        message = 'Ktoś już jest zalogowany na te konto!'
      })
    end)
    .case('CLIENT_ACCOUNT_INVALID_PASSWORD', function()
      securityFault(client)

      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, {
        type = 'login',
        success = false,
        message = 'Podano nieprawidłowe hasło!'
      })
    end)
    -- success
    .case('CLIENT_LOGIN_SUCCESS', function()
      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, { type = 'login', success = true })
    end)
    -- unknown response
    .default(function()
      print('nieznana odpowiedź API', response)

      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, {
        type = 'login',
        success = false,
        message = 'Wystąpił błąd podczas uwierzytelniania (nieznana odpowiedź API)'
      })
    end)
    .process()
  end)
  .case('getPlayerCharacters', function()
    response = API:getAllGameCharacters(client)

    if type(response) == 'string' then
      switch(response)
      .case('CLIENT_PLAYER_NO_CHARACTERS', function()
        triggerClientEvent(client, 'login:onClientResponse', resourceRoot, { type = 'welcome', success = true, characters = {} })
      end)
      .default(function()
        iprint('unknown response', response)
      end).process()
    else
      triggerClientEvent(client, 'login:onClientResponse', resourceRoot, { type = 'welcome', success = true, characters = response })
    end
  end)
  .default(function()
    print('nieznany typ akcji')
  end)
  .process()
end
addEventHandler('login:sendRequest', root, request)