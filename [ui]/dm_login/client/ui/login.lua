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
loginUi.animations = {}

loginUi.init = function()
  loginUi.data.btnSize = Vector2(140 / zoom, 52 / zoom)

  loginUi.data.btnPos = {}
  loginUi.data.btnPos.login = Vector2(50 / zoom, (screen.y - loginUi.data.btnSize.y) / 2)
  loginUi.data.btnPos.register = Vector2(200 / zoom, (screen.y - loginUi.data.btnSize.y) / 2)

  loginUi.fonts.regular = UI:getUIFont('regular')

  loginUi.buttons.login = UI:createButton(loginUi.data.btnPos.login.x, loginUi.data.btnPos.login.y, loginUi.data.btnSize.x, loginUi.data.btnSize.y, 'Zaloguj', true)
  loginUi.buttons.register = UI:createButton(loginUi.data.btnPos.register.x, loginUi.data.btnPos.register.y, loginUi.data.btnSize.x, loginUi.data.btnSize.y, 'Rejestracja', true)

  for btn in pairs(loginUi.buttons) do
    local button = loginUi.buttons[btn]

    if button and isElement(button) then
      UI:setButtonFont(button, loginUi.fonts.regular, 0.85 / zoom)

      loginUi.buttons[button] = nil
    end
  end

  addEventHandler('gui:onClientClickButton', loginUi.buttons.login, function()
    triggerEvent('login:onClientSwitchInterface', resourceRoot)
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
end

loginUi.render = function(alpha, offset)
  for btn in pairs(loginUi.buttons) do
    local button = loginUi.buttons[btn]

    if button and isElement(button) then
      local offX = offset / zoom

      UI:setButtonAlpha(button, alpha)
      UI:setButtonPosition(button, loginUi.data.btnPos[btn].x + offX, loginUi.data.btnPos[btn].y)
    end
  end
end