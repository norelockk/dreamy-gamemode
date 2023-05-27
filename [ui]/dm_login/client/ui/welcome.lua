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

-- welcome screen
welcomeUi = {}
welcomeUi.data = {}
welcomeUi.fonts = {}
welcomeUi.buttons = {}
welcomeUi.textures = {}
welcomeUi.editboxes = {}
welcomeUi.animations = {}

welcomeUi.init = function()
  -- welcome fonts
  welcomeUi.fonts.regular_small = UI:getUIFont('regular_small')

  -- adjust button sizes & positions
  -- welcomeUi.data.btnSize = Vector2(140 / zoom, 52 / zoom)
  -- welcomeUi.data.btnPos = {}
  -- welcomeUi.data.btnPos.back = Vector2(50 / zoom, 460 / zoom)

  -- -- welcome buttons
  -- welcomeUi.buttons.back = UI:createButton(-welcomeUi.data.btnPos.back.x, -welcomeUi.data.btnPos.back.y, welcomeUi.data.btnSize.x, welcomeUi.data.btnSize.y, 'Wróć do logowania', true)

  -- -- setup buttons
  -- UI:setButtonFont(welcomeUi.buttons.back, welcomeUi.fonts.regular_small, 0.85 / zoom)

  -- addEventHandler('gui:onClientClickButton', welcomeUi.buttons.back, welcomeUi.backToLogin)
  addEventHandler('login:onClientResponse', resourceRoot, welcomeUi.response)
end

welcomeUi.render = function(alpha, offset)
  for btn in pairs(welcomeUi.buttons) do
    local button = welcomeUi.buttons[btn]

    if button and isElement(button) then
      local offX = offset / zoom
      local x, y = welcomeUi.data.btnPos[btn].x + offX, welcomeUi.data.btnPos[btn].y

      UI:setButtonAlpha(button, alpha)
      UI:setButtonPosition(button, x, y)
    end
  end
end

welcomeUi.destroy = function()
  removeEventHandler('login:onClientResponse', resourceRoot, welcomeUi.response)

  for btn in pairs(welcomeUi.buttons) do
    local button = welcomeUi.buttons[btn]

    if button and isElement(button) then
      UI:destroyButton(button)

      welcomeUi.buttons[button] = nil
    end
  end
end

welcomeUi.response = function(response)
  if response and response.type == 'welcome' then
    iprint('welcome client response', response)

    if response.success then
      print('success response')
    else
      print('error response', response.message)
    end
  end
end