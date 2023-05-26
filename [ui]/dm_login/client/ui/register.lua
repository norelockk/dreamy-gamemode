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

-- register screen
registerUi = {}
registerUi.data = {}
registerUi.fonts = {}
registerUi.buttons = {}
registerUi.textures = {}
registerUi.editboxes = {}
registerUi.animations = {}

registerUi.init = function()
  -- register fonts
  registerUi.fonts.regular_small = UI:getUIFont('regular_small')

  -- adjust button sizes & positions
  registerUi.data.btnSize = Vector2(140 / zoom, 52 / zoom)
  registerUi.data.btnPos = {}
  registerUi.data.btnPos.back = Vector2(50 / zoom, 460 / zoom)

  -- register buttons
  registerUi.buttons.back = UI:createButton(-registerUi.data.btnPos.back.x, -registerUi.data.btnPos.back.y, registerUi.data.btnSize.x, registerUi.data.btnSize.y, 'Wróć do logowania', true)

  -- setup buttons
  UI:setButtonFont(registerUi.buttons.back, registerUi.fonts.regular_small, 0.85 / zoom)

  addEventHandler('gui:onClientClickButton', registerUi.buttons.back, registerUi.backToLogin)
  addEventHandler('login:onClientResponse', resourceRoot, registerUi.response)
end

registerUi.backToLogin = function()
  triggerEvent('login:onClientSwitchInterface', resourceRoot, 'login')
end

registerUi.render = function(alpha, offset)
  for btn in pairs(registerUi.buttons) do
    local button = registerUi.buttons[btn]

    if button and isElement(button) then
      local offX = offset / zoom
      local x, y = registerUi.data.btnPos[btn].x + offX, registerUi.data.btnPos[btn].y

      UI:setButtonAlpha(button, alpha)
      UI:setButtonPosition(button, x, y)
    end
  end
end

registerUi.destroy = function()
  removeEventHandler('login:onClientResponse', resourceRoot, registerUi.response)

  for btn in pairs(registerUi.buttons) do
    local button = registerUi.buttons[btn]

    if button and isElement(button) then
      UI:destroyButton(button)

      registerUi.buttons[button] = nil
    end
  end
end

registerUi.response = function(response)
  if response and response.type == 'register' then
    iprint('register client response', response)

    if response.success then
      print('success response')
    else
      print('error response', response.message)
    end
  end
end