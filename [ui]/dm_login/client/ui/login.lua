-- screen size n' zooming
local screen = Vector2(guiGetScreenSize())
local zoom = 1920 / screen.x

-- ui
local UI = exports.dm_gui

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
  loginUi.data.btnPos.login = Vector2(50 / zoom, (screen.y - loginUi.data.btnSize.y) / 2)
  loginUi.data.btnPos.register = Vector2(200 / zoom, (screen.y - loginUi.data.btnSize.y) / 2)

  -- register buttons
  loginUi.buttons.login = UI:createButton(loginUi.data.btnPos.login.x, loginUi.data.btnPos.login.y, loginUi.data.btnSize.x, loginUi.data.btnSize.y, 'Zaloguj', true)
  loginUi.buttons.register = UI:createButton(loginUi.data.btnPos.register.x, loginUi.data.btnPos.register.y, loginUi.data.btnSize.x, loginUi.data.btnSize.y, 'Rejestracja', true)

  -- adjust editboxes sizes & positions
  loginUi.data.editSize = Vector2(330 / zoom, 50 / zoom)
  loginUi.data.editPos = {}
  loginUi.data.editPos.login = Vector2(65 / zoom, (screen.y - 710 / zoom) / 2)
  loginUi.data.editPos.password = Vector2(65 / zoom, (screen.y - 570 / zoom) / 2)

  -- register editboxes
  loginUi.editboxes.login = UI:createEditbox('', loginUi.data.editPos.login.x, loginUi.data.editPos.login.y, loginUi.data.editSize.x, loginUi.data.editSize.y, loginUi.fonts.regular_small, 1 / zoom)
  loginUi.editboxes.password = UI:createEditbox('', loginUi.data.editPos.password.x, loginUi.data.editPos.password.y, loginUi.data.editSize.x, loginUi.data.editSize.y, loginUi.fonts.regular_small, 1 / zoom)

  -- setup buttons
  for btn in pairs(loginUi.buttons) do
    local button = loginUi.buttons[btn]

    if button and isElement(button) then
      UI:setButtonFont(button, loginUi.fonts.regular, 0.85 / zoom)
      
      loginUi.buttons[button] = nil
    end
  end
  
  -- setup editboxes
  UI:setEditboxImage(loginUi.editboxes.login, loginUi.textures.user_icon)
  UI:setEditboxHelperText(loginUi.editboxes.login, 'Nazwa użytkownika')

  UI:setEditboxImage(loginUi.editboxes.password, loginUi.textures.password_icon)
  UI:setEditboxHelperText(loginUi.editboxes.password, 'Hasło')
  UI:setEditboxMasked(loginUi.editboxes.password, true)

  addEventHandler('gui:onClientClickButton', loginUi.buttons.login, function()
    -- triggerEvent('login:onClientSwitchInterface', resourceRoot)
  end)
end

loginUi.destroy = function()
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