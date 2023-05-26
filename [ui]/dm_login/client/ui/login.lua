-- screen size n' zooming
local screen = Vector2(guiGetScreenSize())
local zoom = 1920 / screen.x

-- ui
local UI = exports.dm_gui

-- min/max requirements
local DETAILS = {
  USERNAME = {
    MIN = 3,
    MAX = 24
  },
  PASSWORD = {
    MIN = 6,
    MAX = 32
  }
}

-- login screen
loginUi = {}
loginUi.data = {}
loginUi.fonts = {}
loginUi.buttons = {}
loginUi.textures = {}
loginUi.editboxes = {}
loginUi.animations = {}

loginUi.init = function()
  -- register textures
  loginUi.textures.user_icon = dxCreateTexture('assets/images/ui/icons/user.png')
  loginUi.textures.email_icon = dxCreateTexture('assets/images/ui/icons/email.png')
  loginUi.textures.password_icon = dxCreateTexture('assets/images/ui/icons/password.png')

  -- register fonts
  loginUi.fonts.regular = UI:getUIFont('regular')
  loginUi.fonts.regular_small = UI:getUIFont('regular')

  -- adjust button sizes & positions
  loginUi.data.btnSize = Vector2(140 / zoom, 52 / zoom)
  loginUi.data.btnPos = {}
  loginUi.data.btnPos.login = Vector2(50 / zoom, 460 / zoom)
  loginUi.data.btnPos.register = Vector2(200 / zoom, 460 / zoom)

  -- register buttons
  loginUi.buttons.login = UI:createButton(-loginUi.data.btnPos.login.x, -loginUi.data.btnPos.login.y, loginUi.data.btnSize.x, loginUi.data.btnSize.y, 'Zaloguj', true)
  loginUi.buttons.register = UI:createButton(-loginUi.data.btnPos.register.x, -loginUi.data.btnPos.register.y, loginUi.data.btnSize.x, loginUi.data.btnSize.y, 'Rejestracja', true)

  -- adjust editboxes sizes & positions
  loginUi.data.editSize = Vector2(330 / zoom, 50 / zoom)
  loginUi.data.editPos = {}
  loginUi.data.editPos.username = Vector2(70 / zoom, 220 / zoom)
  loginUi.data.editPos.password = Vector2(70 / zoom, 280 / zoom)

  -- register editboxes
  loginUi.editboxes.username = UI:createEditbox('', -loginUi.data.editPos.username.x, -loginUi.data.editPos.username.y, loginUi.data.editSize.x, loginUi.data.editSize.y, loginUi.fonts.regular_small, 1 / zoom)
  loginUi.editboxes.password = UI:createEditbox('', -loginUi.data.editPos.password.x, -loginUi.data.editPos.password.y, loginUi.data.editSize.x, loginUi.data.editSize.y, loginUi.fonts.regular_small, 1 / zoom)

  -- setup buttons
  for btn in pairs(loginUi.buttons) do
    local button = loginUi.buttons[btn]

    if button and isElement(button) then
      UI:setButtonFont(button, loginUi.fonts.regular, 0.85 / zoom)
      
      loginUi.buttons[button] = nil
    end
  end
  
  -- setup editboxes
  UI:setEditboxImage(loginUi.editboxes.username, loginUi.textures.user_icon)
  UI:setEditboxHelperText(loginUi.editboxes.username, 'Nazwa użytkownika')
  UI:setEditboxMaxLength(loginUi.editboxes.username, DETAILS.USERNAME.MAX)

  UI:setEditboxImage(loginUi.editboxes.password, loginUi.textures.password_icon)
  UI:setEditboxMasked(loginUi.editboxes.password, true)
  UI:setEditboxHelperText(loginUi.editboxes.password, 'Hasło')
  UI:setEditboxMaxLength(loginUi.editboxes.password, DETAILS.PASSWORD.MAX)

  -- setup event handlers
  addEventHandler('login:onClientResponse', resourceRoot, loginUi.response)
  addEventHandler('gui:onClientClickButton', loginUi.buttons.login, loginUi.sendLoginRequest)
  addEventHandler('gui:onClientClickButton', loginUi.buttons.register, loginUi.switchToRegister)
end

loginUi.switchToRegister = function()
  triggerEvent('login:onClientSwitchInterface', resourceRoot, 'register')
end

loginUi.switchUiLock = function(state)
  for btn in pairs(loginUi.buttons) do
    local button = loginUi.buttons[btn]

    if button and isElement(button) then
      UI:setButtonEnabled(button, state)
    end
  end
end

loginUi.sendLoginRequest = function()
  local username = UI:getEditboxText(loginUi.editboxes.username)
  local password = UI:getEditboxText(loginUi.editboxes.password)

  if #username < DETAILS.USERNAME.MIN or #username >= DETAILS.USERNAME.MAX then
    print(string.format('Login jest za %s', #username < DETAILS.USERNAME.MIN and 'krótki' or #username >= DETAILS.USERNAME.MAX and 'długi' or ''))
    return
  end

  if #password < DETAILS.PASSWORD.MIN or #password >= DETAILS.PASSWORD.MAX then
    print(string.format('Hasło jest za %s', #password < DETAILS.PASSWORD.MIN and 'krótkie' or #password >= DETAILS.PASSWORD.MAX and 'długie' or ''))
    return
  end

  triggerServerEvent('login:sendRequest', resourceRoot, 'login', {
    username = username,
    password = password
  })
  loginUi.switchUiLock(false)
end

loginUi.destroy = function()
  removeEventHandler('login:onClientResponse', resourceRoot, loginUi.response)
  removeEventHandler('gui:onClientClickButton', loginUi.buttons.login, loginUi.sendLoginRequest)

  for btn in pairs(loginUi.buttons) do
    local button = loginUi.buttons[btn]

    if button and isElement(button) then
      UI:destroyButton(button)

      loginUi.buttons[button] = nil
    end
  end

  for edit in pairs(loginUi.editboxes) do
    UI:destroyEditbox(loginUi.editboxes[edit])
    loginUi.editboxes[edit] = nil
  end

  for texture in pairs(loginUi.textures) do
    destroyElement(loginUi.textures[texture])
    loginUi.textures[texture] = nil
  end
end

loginUi.render = function(alpha, offset)
  for btn in pairs(loginUi.buttons) do
    local button = loginUi.buttons[btn]

    if button and isElement(button) then
      local offX = offset / zoom
      local x, y = loginUi.data.btnPos[btn].x + offX, loginUi.data.btnPos[btn].y

      UI:setButtonAlpha(button, alpha)
      UI:setButtonPosition(button, x, y)
    end
  end

  for edit in pairs(loginUi.editboxes) do
    local editbox = loginUi.editboxes[edit]

    if editbox then
      local offX = offset / zoom
      local x, y = loginUi.data.editPos[edit].x + offX, loginUi.data.editPos[edit].y

      UI:setEditboxAlpha(editbox, alpha * 255)
      UI:setEditboxPosition(editbox, x, y)
    end
  end
end

loginUi.response = function(response)
  if response and response.type == 'login' then
    iprint('login client response', response)

    if response.success then
      print('success response')
      fadeCamera(false)
    else
      print('error response', response.message)
      loginUi.switchUiLock(true)
    end
  end
end